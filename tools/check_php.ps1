try {
    $r = Invoke-WebRequest -Uri 'https://timm-sander.net/sws/api/' -UseBasicParsing
    Write-Output "Status: $($r.StatusCode)"
    Write-Output "X-Powered-By: $($r.Headers['X-Powered-By'])"
    Write-Output "Content-Type: $($r.Headers['Content-Type'])"
} catch {
    Write-Output "Error: $($_.Exception.Message)"
    if ($_.Exception.Response) {
        Write-Output "Status: $([int]$_.Exception.Response.StatusCode)"
    }
}
