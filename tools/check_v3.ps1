$html = (Invoke-WebRequest 'https://timm-sander.net/sws/api/' -UseBasicParsing).Content
if ($html -match 'v3.0-20260629') { 
    Write-Output 'v3.0 Marker: GEFUNDEN - Server ist aktuell!' 
} else { 
    Write-Output 'v3.0 Marker: FEHLT - Server liefert alte Version!'
    Write-Output "HTML length: $($html.Length)"
}
