$r = Invoke-WebRequest -Uri 'https://timm-sander.net/sws/api/' -UseBasicParsing
$body = $r.Content
Write-Output "Length: $($body.Length)"
if ($body -match 'sws-login-page') { Write-Output "Login page: YES" }
if ($body -match 'SWS Admin – Login') { Write-Output "Title: YES" }
if ($body -match 'name="username"') { Write-Output "Form: YES" }
if ($body -match 'parse error|fatal error|uncaught', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase) { 
    Write-Output "PHP ERROR DETECTED!"
    Write-Output $body.Substring(0, 500)
} else {
    Write-Output "No PHP errors detected in output."
    Write-Output "First 200 chars: $($body.Substring(0, 200))"
}
