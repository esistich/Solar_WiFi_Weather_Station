$url = 'https://timm-sander.net/sws/api/'
Write-Output "Testing: $url"
try {
    $response = Invoke-WebRequest -Uri $url -UseBasicParsing -Method GET -MaximumRedirection 0 -ErrorAction Stop
    Write-Output "Status: $($response.StatusCode)"
    Write-Output "First 500 chars:"
    Write-Output $response.Content.Substring(0, [Math]::Min(500, $response.Content.Length))
} catch [System.Net.WebException] {
    $resp = $_.Exception.Response
    if ($resp) {
        Write-Output "Status: $([int]$resp.StatusCode)"
        Write-Output "Location: $($resp.Headers['Location'])"
        $sr = New-Object System.IO.StreamReader($resp.GetResponseStream())
        $body = $sr.ReadToEnd()
        $sr.Close()
        Write-Output "Body (first 500): $($body.Substring(0, [Math]::Min(500, $body.Length)))"
    } else {
        Write-Output "Error: $($_.Exception.Message)"
    }
} catch {
    Write-Output "Error: $($_.Exception.Message)"
}
