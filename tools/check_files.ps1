$files = @('admin.css', 'admin.js', 'admin.php')
foreach ($f in $files) {
    $url = "https://timm-sander.net/sws/api/$f"
    try {
        $r = Invoke-WebRequest -Uri $url -UseBasicParsing -ErrorAction Stop
        Write-Output "$f : $($r.StatusCode) $($r.Content.Length) bytes"
    } catch {
        Write-Output "$f : ERROR $($_.Exception.Message)"
    }
}
