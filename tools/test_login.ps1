$loginUrl = 'https://timm-sander.net/sws/api/?action=login'
$dashboardUrl = 'https://timm-sander.net/sws/api/'

# Read credentials from .env
$envPath = Join-Path $PSScriptRoot '..' '.env'
$envContent = Get-Content $envPath -Raw
$adminUser = ''
$adminPass = ''
foreach ($line in $envContent -split "`n") {
    if ($line -match '^ADMIN_USER=(.+)$') { $adminUser = $Matches[1].Trim() }
    if ($line -match '^ADMIN_PASS=(.+)$') { $adminPass = $Matches[1].Trim() }
}
Write-Output "Admin user: $adminUser"

$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession

# Step 1: Login
try {
    $loginResp = Invoke-WebRequest -Uri $loginUrl -Method POST -Body "username=$adminUser&password=$adminPass" -ContentType 'application/x-www-form-urlencoded' -UseBasicParsing -WebSession $session -MaximumRedirection 0 -ErrorAction Stop
    Write-Output "Login Status: $($loginResp.StatusCode)"
    Write-Output "Login Location: $($loginResp.Headers['Location'])"
} catch [System.Net.WebException] {
    $resp = $_.Exception.Response
    if ($resp.StatusCode -eq 'Found' -or $resp.StatusCode -eq 'Redirect') {
        Write-Output "Login redirect (expected): $([int]$resp.StatusCode) -> $($resp.Headers['Location'])"
    } else {
        Write-Output "Login failed: $([int]$resp.StatusCode)"
        if ($resp) {
            $sr = New-Object System.IO.StreamReader($resp.GetResponseStream())
            Write-Output "Body: $($sr.ReadToEnd().Substring(0, [Math]::Min(500, $sr.ReadToEnd().Length)))"
            $sr.Close()
        }
    }
}

# Step 2: Get dashboard
try {
    $dashResp = Invoke-WebRequest -Uri $dashboardUrl -UseBasicParsing -WebSession $session -ErrorAction Stop
    Write-Output "Dashboard Status: $($dashResp.StatusCode)"
    $body = $dashResp.Content
    Write-Output "Dashboard Length: $($body.Length)"
    # Check for key elements
    if ($body -match 'sws-sidebar') { Write-Output "Sidebar: FOUND" } else { Write-Output "Sidebar: MISSING" }
    if ($body -match 'sws-content') { Write-Output "Content: FOUND" } else { Write-Output "Content: MISSING" }
    if ($body -match 'error|Error|Fatal|fatal|Warning|Parse error') { 
        $match = [regex]::Match($body, '(?:Fatal error|Parse error|Warning)[^<]{0,300}')
        if ($match.Success) { Write-Output "PHP Error: $($match.Value)" }
    }
    # Show first 300 chars
    Write-Output "First 300: $($body.Substring(0, [Math]::Min(300, $body.Length)))"
} catch [System.Net.WebException] {
    $resp = $_.Exception.Response
    Write-Output "Dashboard Error: $([int]$resp.StatusCode)"
    $sr = New-Object System.IO.StreamReader($resp.GetResponseStream())
    $body = $sr.ReadToEnd()
    $sr.Close()
    Write-Output "Error Body (first 500): $($body.Substring(0, [Math]::Min(500, $body.Length)))"
}
