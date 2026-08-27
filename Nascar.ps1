# 🏎️ NASCAR MODE: High-Performance FL Studio Profile (Mid-Flight)
Write-Host "🏁 Initiating NASCAR execution state..." -ForegroundColor Red

# 1. Targeted Process Annihilation
$TargetsToKill = @("Spotify", "OneDrive", "Teams", "PowerToys", "Ollama", "Figma", "Warp", "Cursor", "Visual Studio Code", "LibreOffice", "Calibre", "Comet", "Noi")

foreach ($app in $TargetsToKill) {
    if (Get-Process -Name $app -ErrorAction SilentlyContinue) {
        Stop-Process -Name $app -Force -ErrorAction SilentlyContinue
        Write-Host "🛑 Parked background process: $app" -ForegroundColor Yellow
    }
}

# 2. Check for Active FL Studio Instances & Elevate
$FLProcesses = Get-Process -Name "FL64" -ErrorAction SilentlyContinue

if ($FLProcesses) {
    Write-Host "🎹 FL Studio detected. Elevating priority..." -ForegroundColor Green
    
    # Loop through all associated FL64 threads just in case it returns an array
    foreach ($proc in $FLProcesses) {
        try {
            $proc.PriorityClass = [System.Diagnostics.ProcessPriorityClass]::High
        } catch {
            Write-Host "⚠️ Could not set priority for process ID $($proc.Id). (May require Admin)" -ForegroundColor DarkYellow
        }
    }
    Write-Host "⚡ FL Studio priority pinned to HIGH PERFORMANCE CORE STATUS." -ForegroundColor Cyan
} else {
    Write-Host "❌ FL Studio is NOT currently running. NASCAR mode standing by." -ForegroundColor Red
}