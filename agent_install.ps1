# openbasfontys@gmail.com
# OpenBAS_P1

param (
    [string]$openbas_server_ip,
    [string]$openbasusername,
    [string]$openbaspassword
)

$usage = "Usage: .\agent_install.ps1 openbas_server_ip openbas_username openbas_password"

if ($PSVersionTable.PSVersion.Major -ne 7) {
    Write-Output "OpenBAS agent requires Powershell version 7 (pwsh.exe)"
    Write-Output "This script will try installing it for you"
    winget install Microsoft.Powershell --accept-package-agreements --accept-source-agreements
    Write-Output "Please run the script with Powershell 7"
}

if (-not $openbas_server_ip) {
    Write-Output "Missing parameters"
    Write-Output $usage
    exit 1
}

if (-not $openbasusername) {
    Write-Output "Missing the second and third parameters"
    Write-Output $usage
    exit 1
}

if (-not $openbaspassword) {
    Write-Output "Missing the third parameter"
    Write-Output $usage
    exit 1
}

# Enable long file paths
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" `
    -Name "LongPathsEnabled" -Value 1 -PropertyType DWORD -Force

# Base URL (fixed concatenation)
$openbas_base_url = "http://$openbas_server_ip:8080"

# Antivirus exclusions
Add-MpPreference -ExclusionProcess "openbas-agent.exe"
Add-MpPreference -ExclusionPath "C:\Program Files (x86)\Filigran\OBAS Agent\"
Add-MpPreference -ExclusionPath "C:\Program Files (x86)\Filigran\OBAS Agent\openbas-agent.exe"

# Web session
$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$session.UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"

# JSON body (fixed escaping & interpolation)
$loginBody = @{
    login    = $openbasusername
    password = $openbaspassword
} | ConvertTo-Json

# Login request
$rawContent = (Invoke-WebRequest -UseBasicParsing `
    -Uri "$openbas_base_url/api/login" `
    -Method POST `
    -WebSession $session `
    -Headers @{
        "Accept"          = "application/json, text/plain, */*"
        "Accept-Encoding" = "gzip, deflate"
        "Accept-Language" = "en-US,en;q=0.9"
        "Origin"          = $openbas_base_url
        "Referer"         = "$openbas_base_url/"
        "responseType"    = "json"
    } `
    -ContentType "application/json" `
    -Body $loginBody
).RawContent

# Extract cookie
$cookiePattern = 'Set-Cookie:\s*JSESSIONID=([^;]+)'

if ($rawContent -match $cookiePattern) {
    $jsessionId = $matches[1]
    Write-Output "Authentication success"
} else {
    Write-Output "Invalid credentials"
    exit 1
}

# Attach cookie (fixed domain interpolation)
$session.Cookies.Add(
    (New-Object System.Net.Cookie("JSESSIONID", $jsessionId, "/", $openbas_server_ip))
)

# Token URL
$token_url = "$openbas_base_url/api/me/tokens"

$res = (Invoke-WebRequest -UseBasicParsing `
    -Uri $token_url `
    -WebSession $session `
    -Headers @{
        "Accept"          = "application/json, text/plain, */*"
        "Accept-Encoding" = "gzip, deflate"
        "Accept-Language" = "en-US,en;q=0.9"
        "Referer"         = "$openbas_base_url/admin/agents"
        "responseType"    = "json"
    }
).Content | ConvertFrom-Json

$token = $res.token_value

# Agent installer URL
$agent_url = "$openbas_base_url/api/agent/installer/openbas/windows/service/$token"

iex (iwr -UseBasicParsing $agent_url).Content

Write-Output "Machine will restart for changes to take effect in 7 seconds"
Start-Sleep 7
Restart-Computer
