$Model = knowledgeos:latest
$DownloadRoot = "$env:USERPROFILE\Downloads\AI_Smart_$(Get-Date -Format yyyyMMdd_HHmmss)"
New-Item -ItemType Directory -Force -Path $DownloadRoot | Out-Null

# 1. Get URLs from current Edge window
$edgeSessions = Get-ChildItem "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Sessions" -Filter "*.json" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
$sessionData = Get-Content $edgeSessions.FullName -Raw | ConvertFrom-Json
$urls = $sessionData.windows.tabs.url | Sort-Object -Unique

$allDownloads = @()

foreach ($url in $urls) {
    Write-Host "`nProcessing $url" -ForegroundColor Cyan

    try {
        $html = Invoke-WebRequest -Uri $url -UseBasicParsing -ErrorAction Stop
    }
    catch {
        Write-Host "Failed to fetch HTML" -ForegroundColor Red
        continue
    }

    $prompt = Get-Content "ollama_prompt.txt" -Raw
    $prompt = $prompt.Replace("[HTML_CONTENT_HERE]", $html.Content)

    $response = ollama run $Model --prompt $prompt

    try {
        $json = $response | ConvertFrom-Json
        $allDownloads += $json.downloads
    }
    catch {
        Write-Host "Invalid JSON from Ollama" -ForegroundColor Red
    }
}

# Confirmation
Write-Host "`nFound $($allDownloads.Count) downloadable items:"
$allDownloads | Format-Table direct_url, file_type, confidence, is_primary

$confirm = Read-Host "Download these files? (y/n)"
if ($confirm -ne "y") { exit }

# Download
foreach ($item in $allDownloads) {
    $url = $item.direct_url
    $fileName = Split-Path ([Uri]$url).AbsolutePath -Leaf
    if (-not $fileName) { $fileName = [guid]::NewGuid().ToString() }

    $out = Join-Path $DownloadRoot $fileName

    Write-Host "Downloading $url"
    Invoke-WebRequest -Uri $url -OutFile $out -UseBasicParsing
}

Write-Host "`nDone. Files saved to $DownloadRoot"
