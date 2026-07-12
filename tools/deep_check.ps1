# Check if the server's admin.php has the new sidebar items
$html = (Invoke-WebRequest -Uri 'https://timm-sander.net/sws/api/' -UseBasicParsing).Content
Write-Output "Server HTML length: $($html.Length)"
$checks = @('System-Log', 'Log-Statistik', 'Server-Info', 'Diagnose', 'admin_v2.js', 'admin_v2.css')
foreach ($c in $checks) {
    if ($html -match [regex]::Escape($c)) { Write-Output "  $c : OK" }
    else { Write-Output "  $c : FEHLT!" }
}

# Also try the admin/ path
$html2 = (Invoke-WebRequest -Uri 'https://timm-sander.net/sws/api/admin/' -UseBasicParsing).Content
Write-Output "`n/admin/ HTML length: $($html2.Length)"
foreach ($c in $checks) {
    if ($html2 -match [regex]::Escape($c)) { Write-Output "  $c : OK" }
    else { Write-Output "  $c : FEHLT!" }
}
