$url = 'https://timm-sander.net/sws/api/admin.php'
$r = Invoke-WebRequest -Uri $url -UseBasicParsing
$h = $r.Content
Write-Output "admin.php direct: $($h.Length) bytes"
$checks = @('admin_v2.js', 'admin_v2.css', 'toggleSidebar', 'System-Log', 'Diagnose')
foreach ($c in $checks) {
    if ($h -match [regex]::Escape($c)) { Write-Output "  $c : OK" }
    else { Write-Output "  $c : FEHLT!" }
}
