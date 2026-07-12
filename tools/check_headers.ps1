$r = Invoke-WebRequest -Uri 'https://timm-sander.net/sws/api/' -UseBasicParsing
Write-Output "Cache-Control: $($r.Headers['Cache-Control'])"
Write-Output "Pragma: $($r.Headers['Pragma'])"
Write-Output "Length: $($r.Content.Length)"
# Check if new cache buster is in the HTML
if ($r.Content -match '2026062912') { Write-Output "Cache-Buster v=2026062912: OK" }
else { Write-Output "Cache-Buster v=2026062912: FEHLT" }
