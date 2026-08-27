# -------------------------
# CLEANUP SWEEP
# -------------------------

Write-Host " Running safe cleanup sweep… " -ForegroundColor Cyan

$targetPaths = @(
    "$env:LOCALAPPDATA",
    "$env:APPDATA",
    "$env:PROGRAMDATA"
)

$killPatterns = @(
    "steam", "epic", "origin", "ea", "anticheat",
    "crashpad", "telemetry", "mcafee", "wildtangent"
)

foreach ($base in $targetPaths) {
    Get-ChildItem $base | ForEach-Object {
        foreach ($pattern in $killPatterns) {
            if ($_.Name -like "*$pattern*") {
                Write-Host " → Wiping: $($_.FullName)" -ForegroundColor Yellow
                Remove-Item $_.FullName -Recurse -Force -ErrorAction SilentlyContinue
            }
        }
    }
}

Write-Host " Sweep done. " -ForegroundColor Green
