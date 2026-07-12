$content = (Invoke-WebRequest -Uri 'https://timm-sander.net/wp-content/debug.log' -UseBasicParsing).Content
$lines = $content -split "`n"
$swsLines = $lines | Select-String -Pattern 'sws|SWS|admin\.php|admin_api|helpers|system_log' -CaseSensitive:$false
$swsLines | Select-Object -Last 30 | Write-Output
