Write-Host " Removing Omnisphere ONLY…" -ForegroundColor Cyan

$paths = @(
    "$env:PROGRAMDATA\Spectrasonics\STEAM\Omnisphere",
    "$env:PROGRAMFILES\Spectrasonics\Omnisphere",
    "$env:APPDATA\Spectrasonics\Omnisphere",
    "$env:LOCALAPPDATA\Spectrasonics\Omnisphere"
)

foreach ($p in $paths) {
    if (Test-Path $p) {
        Write-Host " → Removing $p" -ForegroundColor Red
        Remove-Item $p -Recurse -Force
    }
}

Write-Host " Omnisphere purge complete. " -ForegroundColor Green
