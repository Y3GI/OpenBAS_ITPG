param(
    [int]$Threads = 50,
    [int]$TimeoutMs = 1500
)

# ----------------------------
# Get local IPv4 network ranges
# ----------------------------
function Get-LocalSubnets {
    $subnets = @()

    Get-NetIPConfiguration |
        Where-Object {
            $_.IPv4Address -and
            $_.NetAdapter.Status -eq 'Up'
        } |
        ForEach-Object {
            foreach ($ip in $_.IPv4Address) {
                $subnets += "$($ip.IPAddress)/$($ip.PrefixLength)"
            }
        }

    $subnets | Sort-Object -Unique
}

# ----------------------------
# Expand CIDR to IP list
# ----------------------------
function Expand-CIDR {
    param([string]$CIDR)

    $ip, $prefix = $CIDR -split '/'
    $ipBytes = [System.Net.IPAddress]::Parse($ip).GetAddressBytes()
    [array]::Reverse($ipBytes)
    $ipInt = [BitConverter]::ToUInt32($ipBytes, 0)

    $mask = [uint32]::MaxValue -shl (32 - [int]$prefix)
    $network = $ipInt -band $mask
    $broadcast = $network + ([uint32]::MaxValue -shr [int]$prefix)

    for ($i = $network + 1; $i -lt $broadcast; $i++) {
        $b = [BitConverter]::GetBytes($i)
        [array]::Reverse($b)
        ([System.Net.IPAddress]::new($b)).ToString()
    }
}

# ----------------------------
# Quick SMB port check
# ----------------------------
function Test-SMBPort {
    param($IP)

    try {
        $client = New-Object System.Net.Sockets.TcpClient
        $iar = $client.BeginConnect($IP, 445, $null, $null)
        if (-not $iar.AsyncWaitHandle.WaitOne($TimeoutMs)) {
            $client.Close()
            return $false
        }
        $client.EndConnect($iar)
        $client.Close()
        return $true
    }
    catch {
        return $false
    }
}

# ----------------------------
# Anonymous SMB share listing
# ----------------------------
function Get-SMBShares {
    param($IP)

    $output = net view "\\$IP" 2>$null
    if ($LASTEXITCODE -ne 0) {
        return $null
    }

    foreach ($line in $output) {
        if ($line -match '^\s*(\S+)\s+(Disk|Printer)\s*(.*)$') {
            [pscustomobject]@{
                IP      = $IP
                Share   = $Matches[1]
                Type    = $Matches[2]
                Comment = $Matches[3].Trim()
            }
        }
    }
}

# ----------------------------
# Main execution
# ----------------------------
$targets = @()

foreach ($subnet in Get-LocalSubnets) {
    $targets += Expand-CIDR $subnet
}

$targets = $targets | Sort-Object -Unique

$runspacePool = [runspacefactory]::CreateRunspacePool(1, $Threads)
$runspacePool.Open()
$jobs = @()

foreach ($ip in $targets) {
    $ps = [powershell]::Create()
    $ps.RunspacePool = $runspacePool

    $ps.AddScript({
        param($ip)

        if (-not (Test-SMBPort $ip)) { return }

        Get-SMBShares $ip
    }).AddArgument($ip) | Out-Null

    $jobs += [pscustomobject]@{
        PS     = $ps
        Handle = $ps.BeginInvoke()
    }
}

foreach ($job in $jobs) {
    $job.PS.EndInvoke($job.Handle)
    $job.PS.Dispose()
}

$runspacePool.Close()
