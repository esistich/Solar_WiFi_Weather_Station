$files = @{
    'admin.php' = @{ size = 0; keyword = 'Diagnose' }
    'admin.js'  = @{ size = 0; keyword = 'toggleSidebar' }
    'admin.css' = @{ size = 0; keyword = '@media' }
}
foreach ($f in $files.Keys) {
    $url = "https://timm-sander.net/sws/api/$f"
    try {
        $r = Invoke-WebRequest -Uri $url -UseBasicParsing -ErrorAction Stop
        $found = $r.Content -match [regex]::Escape($files[$f].keyword)
        Write-Output "$f : $($r.Content.Length)B | '$($files[$f].keyword)': $(if($found){'OK'}else{'FEHLT!'})"
    } catch {
        Write-Output "$f : ERROR"
    }
}
