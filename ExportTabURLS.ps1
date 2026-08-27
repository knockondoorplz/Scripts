# Export all URLs from the current Edge window
$edgeSessions = Get-ChildItem "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Sessions" -Filter "*.json" | Sort-Object LastWriteTime -Descending | Select-Object -First 1

$sessionData = Get-Content $edgeSessions.FullName -Raw | ConvertFrom-Json

$urls = $sessionData.windows.tabs.url | Sort-Object -Unique

$urls | Out-File "$env:USERPROFILE\Desktop\edge_tabs.txt"

Write-Host "Saved $(($urls).Count) URLs to Desktop\edge_tabs.txt"
