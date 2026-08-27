$UrlFile = "$env:USERPROFILE\Desktop\edge_tabs.txt"
$DownloadFolder = "$env:USERPROFILE\Downloads\AI_Blast_$(Get-Date -Format yyyyMMdd_HHmmss)"

New-Item -ItemType Directory -Force -Path $DownloadFolder | Out-Null

$urls = Get-Content $UrlFile | Where-Object { $_ -match "^https?://" }

foreach ($url in $urls) {
    try {
        $fileName = Split-Path ([Uri]$url).AbsolutePath -Leaf
        if (-not $fileName) { $fileName = [guid]::NewGuid().ToString() }

        $out = Join-Path $DownloadFolder $fileName

        Write-Host "Downloading $url"
        Invoke-WebRequest -Uri $url -OutFile $out -UseBasicParsing -ErrorAction Stop
    }
    catch {
        Write-Host "Failed: $url" -ForegroundColor Red
    }
}

Write-Host "Done. Files saved to $DownloadFolder"
