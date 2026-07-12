# Test login with dummy credentials
$url = 'https://timm-sander.net/sws/api/?action=login'
$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession

try {
    $r = Invoke-WebRequest -Uri $url -Method POST -Body 'username=test&password=test' -ContentType 'application/x-www-form-urlencoded' -UseBasicParsing -WebSession $session -MaximumRedirection 0 -ErrorAction Stop
    Write-Output "Status: $($r.StatusCode)"
    Write-Output "Location: $($r.Headers['Location'])"
} catch [System.Net.WebException] {
    $resp = $_.Exception.Response
    if ($resp.StatusCode -eq 'Found' -or [int]$resp.StatusCode -eq 302) {
        Write-Output "Login redirect (unexpected success with dummy creds): $([int]$resp.StatusCode) -> $($resp.Headers['Location'])"
    } else {
        Write-Output "Status: $([int]$resp.StatusCode)"
        $sr = New-Object System.IO.StreamReader($resp.GetResponseStream())
        $body = $sr.ReadToEnd()
        $sr.Close()
        Write-Output "Body preview: $($body.Substring(0, [Math]::Min(200, $body.Length)))"
        # Check for PHP errors
        if ($body -match 'error|Error|Fatal|fatal|Parse|Warning|Notice', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase) {
            Write-Output "POSSIBLE PHP ERROR!"
        }
        if ($body -match 'Benutzername oder Passwort falsch') {
            Write-Output "Login form shown with error message - normal behavior"
        }
    }
}
