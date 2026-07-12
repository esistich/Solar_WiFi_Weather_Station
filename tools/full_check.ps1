# Deep check: download and analyze the actual server HTML
$html = (Invoke-WebRequest -Uri 'https://timm-sander.net/sws/api/' -UseBasicParsing).Content
Write-Output "=== LOGIN PAGE ==="
Write-Output "Length: $($html.Length)"
Write-Output "--- Full content ---"
Write-Output $html
Write-Output "=== END ==="

# Also check the dashboard by trying with a cookie
# We can't, but let's check if admin.php source has our unique markers
# by looking for strings that only exist in the new login page
$markers = @('admin_v2.css', 'Cache-Control', 'no-store')
foreach ($m in $markers) {
    if ($html -match [regex]::Escape($m)) { Write-Output "MARKER $m : PRESENT" }
    else { Write-Output "MARKER $m : MISSING" }
}
