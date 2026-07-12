# Test systemlog endpoint
$url = 'https://timm-sander.net/sws/api/?action=api/systemlog'
$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession

try {
    $r = Invoke-WebRequest -Uri $url -UseBasicParsing -WebSession $session -ErrorAction Stop
    Write-Output "Status: $($r.StatusCode)"
    Write-Output "Content: $($r.Content)"
} catch {
    Write-Output "Error: $($_.Exception.Message)"
    if ($_.Exception.Response) {
        $sr = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        Write-Output "Body: $($sr.ReadToEnd())"
        $sr.Close()
    }
}
