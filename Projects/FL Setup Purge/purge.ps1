# -------------------------
# MODERN PURGE SCRIPT (PS7+)
# -------------------------

Write-Host " Starting modern purge…" -ForegroundColor Cyan

$killList = @(
    "Steam",
    "Epic Games",
    "Vulkan Run Time",
    "WildTangent",
    "GameInput",
    "Xbox",
    "Gaming Services",
    "EA App",
    "EA Desktop",
    "Origin",
    "HP Wolf",
    "HP Sure Sense",
    "HP Analytics",
    "HP Documentation",
    "iTop",
    "Segurazo",
    "Lavasoft",
    "McAfee",
    "NordPass",
    "OneDrive",
    "Dropbox",
    "Google Update",
    "Update Health Tools"
)

foreach ($name in $killList) {

    Write-Host " → Searching for: $name" -ForegroundColor Yellow

    # Try Winget first (modern)
    $match = winget list --source winget | Select-String $name
    if ($match) {
        Write-Host "   → Uninstalling via winget: $name" -ForegroundColor Red
        winget uninstall --id (winget list --source winget | Select-String $name | ForEach-Object {
            ($_ -split '\s{2,}')[0]
        }) --silent --force
        continue
    }

    # Try Get-Package (fallback)
    $pkgs = Get-Package | Where-Object { $_.Name -like "*$name*" }
    foreach ($pkg in $pkgs) {
        Write-Host "   → Uninstalling via Get-Package: $($pkg.Name)" -ForegroundColor Red
        $pkg | Uninstall-Package -Force -ErrorAction SilentlyContinue
    }

    # Try MSI uninstall (nuclear option)
    $msi = Get-CimInstance Win32_Product -ErrorAction SilentlyContinue | Where-Object { $_.Name -like "*$name*" }
    foreach ($m in $msi) {
        Write-Host "   → MSI uninstall: $($m.Name)" -ForegroundColor Red
        msiexec.exe /x $m.IdentifyingNumber /qn /norestart
    }
}

# CLEAN LEFTOVER FOLDERS
$folders = @(
    "$env:PROGRAMFILES\Steam",
    "$env:PROGRAMFILES\Epic Games",
    "$env:PROGRAMFILES(X86)\Origin",
    "$env:LOCALAPPDATA\Steam",
    "$env:LOCALAPPDATA\EpicGamesLauncher",
    "$env:LOCALAPPDATA\Origin",
    "$env:LOCALAPPDATA\Crashpad",
    "$env:LOCALAPPDATA\Microsoft\OneDrive",
    "$env:PROGRAMDATA\EA",
    "$env:PROGRAMDATA\Origin",
    "$env:PROGRAMDATA\McAfee"
)

foreach ($f in $folders) {
    if (Test-Path $f) {
        Write-Host " → Removing folder: $f" -ForegroundColor Red
        Remove-Item $f -Recurse -Force -ErrorAction SilentlyContinue
    }
}

Write-Host " Purge complete. " -ForegroundColor Green
