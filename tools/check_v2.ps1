$files = @('admin_v2.js', 'admin_v2.css')
foreach ($f in $files) {
    $url = "https://timm-sander.net/sws/api/$f"
    try {
        $r = Invoke-WebRequest -Uri $url -UseBasicParsing
        Write-Output "$f : $($r.StatusCode) $($r.Content.Length) bytes"
    } catch {
        Write-Output "$f : ERROR $($_.Exception.Message)"
    }
}
# Also check admin.php for the new references
$html = (Invoke-WebRequest -Uri 'https://timm-sander.net/sws/api/' -UseBasicParsing).Content
if ($html -match 'admin_v2.js') { Write-Output "admin_v2.js reference in HTML: OK" } else { Write-Output "admin_v2.js reference in HTML: FEHLT" }
if ($html -match 'admin_v2.css') { Write-Output "admin_v2.css reference in HTML: OK" } else { Write-Output "admin_v2.css reference in HTML: FEHLT" }
