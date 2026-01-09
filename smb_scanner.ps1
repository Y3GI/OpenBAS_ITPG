param(
    [Parameter(Mandatory)]
    [string[]]$Targets,

    [int]$Threads = 50,
    [int]$TimeoutMs = 2000
)

function Expand-Targets {
    param($InputTargets)

    $results = @()

    foreach ($t in $InputTargets) {
        if ($t -match '/') {
            $ip, $cidr = $t -split '/'
            $ipBytes = [System.Net.IPAddress]::Parse($ip).GetAddressBytes()
            [array]::Reverse($ipBytes)
            $ipInt = [BitConverter]::ToUInt32($ipBytes,0)
            $mask = [uint32]::MaxValue -shl (32 - [int]$cidr)
            $network = $ipInt -band $mask
            $broadcast = $network + ([uint32]::MaxValue -shr [int]$cidr)

            for ($i = $network + 1; $i -lt $broadcast; $i++) {
                $b = [BitConverter]::GetBytes($i)
                [array]::Reverse($b)
                $results += ([System.Net.IPAddress]::new($b)).ToString()
            }
        } else {
            $results += $t
        }
    }
    $results
}

function Test-SMB {
    param($Target)

    $result = [ordered]@{
        Target        = $Target
        SMB           = $false
        SMB1          = $false
        SMB2          = $false
        SMB3          = $false
        Signing       = "Unknown"
        Error         = $null
    }

    try {
        $client = New-Object System.Net.Sockets.TcpClient
        $iar = $client.BeginConnect($Target, 445, $null, $null)
        if (-not $iar.AsyncWaitHandle.WaitOne($TimeoutMs)) {
            throw "Timeout"
        }
        $client.EndConnect($iar)
        $stream = $client.GetStream()

        # SMB2 NEGOTIATE (supports SMB2/3 detection)
        $packet = [byte[]](
            0x00,0x00,0x00,0xA4,
            0xFE,0x53,0x4D,0x42,0x40,0x00,0x00,0x00,
            0x00,0x00,0x00,0x00,
            0x00,0x00,0x00,0x00,
            0x00,0x00,0x00,0x00,
            0x00,0x00,0x00,0x00,
            0x00,0x00,0x00,0x00,
            0x24,0x00,
            0x05,0x00,
            0x01,0x00,
            0x00,0x00,
            0x02,0x02,
            0x10,0x02,
            0x11,0x03,
            0x02,0x03,
            0x00,0x00
        )

        $stream.Write($packet,0,$packet.Length)
        $buffer = New-Object byte[] 1024
        $stream.Read($buffer,0,1024) | Out-Null

        if ($buffer[4] -eq 0xFE) {
            $result.SMB = $true
            $result.SMB2 = $true

            # Dialect
            $dialect = [BitConverter]::ToUInt16($buffer, 72)
            if ($dialect -ge 0x0300) { $result.SMB3 = $true }

            # Signing
            $secMode = [BitConverter]::ToUInt16($buffer, 70)
            $result.Signing = if ($secMode -band 0x02) { "Required" } else { "Not Required" }
        }

        $client.Close()
    }
    catch {
        $result.Error = $_.Exception.Message
    }

    [pscustomobject]$result
}

$expanded = Expand-Targets $Targets

$runspacePool = [runspacefactory]::CreateRunspacePool(1, $Threads)
$runspacePool.Open()
$jobs = @()

foreach ($t in $expanded) {
    $ps = [powershell]::Create()
    $ps.RunspacePool = $runspacePool
    $ps.AddScript(${function:Test-SMB}).AddArgument($t) | Out-Null
    $jobs += [pscustomobject]@{ PS = $ps; Handle = $ps.BeginInvoke() }
}

foreach ($j in $jobs) {
    $j.PS.EndInvoke($j.Handle)
    $j.PS.Dispose()
}

$runspacePool.Close()
