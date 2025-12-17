param (
      [string]$hostname
)

$usage = "Usage: .\agent_install.ps1 openbas_url"

if (-not $hostname) {
    echo "Missing hostname"
    echo $usage
    exit 1
}

# Enable long file paths for the OpenBAS agent
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -Value 1 -PropertyType DWORD -Force

$openbas_base_url = "http://$hostname" + ":8080"

# Add antivirus exclusions
add-mppreference -ExclusionProcess "openbas-agent.exe"
add-mppreference -ExclusionPath "C:\Program Files (x86)\Filigran\OBAS Agent\openbas-agent.exe"

# Create the WebRequestSession object
$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$session.UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0"
$session.Cookies.Add((New-Object System.Net.Cookie("JSESSIONID", "247A28C82F6EF607ADB7077F2035AE90", "/", $hostname)))

# Construct the URL using the provided hostname
$token_url = $openbas_base_url + "/api/me/tokens"
# Make the web request to the specified URL
$res = (Invoke-WebRequest -UseBasicParsing -Uri $token_url `
-WebSession $session `
-Headers @{
    "Accept"="application/json, text/plain, */*"
    "Accept-Encoding"="gzip, deflate"
    "Accept-Language"="en-US,en;q=0.9"
    "Referer"="http://$hostname:8080/admin/agents"
    "responseType"="json"
}).Content | ConvertFrom-Json

# Output the token value
$token = $res.token_value
$agent_url = $openbas_base_url + "/api/agent/installer/openbas/windows/service/$token"
iex (iwr $agent_url).Content

# Restart for the long paths registry to take effect
echo "Machine will restart for changes to take effect in 7 seconds"
Start-Sleep 7
Restart-Computer
