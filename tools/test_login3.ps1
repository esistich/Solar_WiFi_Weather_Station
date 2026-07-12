# Test login and check for PHP errors
$url = 'https://timm-sander.net/sws/api/?action=login'
$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession

try {
    $r = Invoke-WebRequest -Uri $url -Method POST -Body 'username=test&password=test' -ContentType 'application/x-www-form-urlencoded' -UseBasicParsing -WebSession $session -ErrorAction Stop
    $body = $r.Content
    Write-Output "Status: $($r.StatusCode)"
    Write-Output "Body: $body"
} catch {
    Write-Output "Error: $($_.Exception.Message)"
}
