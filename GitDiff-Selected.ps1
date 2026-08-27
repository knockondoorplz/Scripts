# GitDiff-Selected.ps1
# Usage: Pass two file paths as arguments.
# AHK will call: powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Users\brigi\Documents\Jason\Scripts\GitDiff-Selected.ps1" "file1" "file2"

param(
    [Parameter(Mandatory=$true)] [string]$File1,
    [Parameter(Mandatory=$true)] [string]$File2
)

if (-not (Test-Path $File1)) { Write-Error "File not found: $File1"; pause; exit 1 }
if (-not (Test-Path $File2)) { Write-Error "File not found: $File2"; pause; exit 1 }

Write-Host "=== git diff ===" -ForegroundColor Cyan
Write-Host "  A: $File1" -ForegroundColor Yellow
Write-Host "  B: $File2" -ForegroundColor Yellow
Write-Host ""

git diff --no-index -- $File1 $File2

Write-Host ""
Write-Host "Press any key to close..." -ForegroundColor DarkGray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")