# IconRestore.ps1 - Bulk Re-apply Custom Icons from CSV
$backupCsv = "$env:USERPROFILE\Desktop\CustomIconsBackup.csv"

if (!(Test-Path $backupCsv)) {
    Write-Host "Error: Cannot find $backupCsv on your Desktop!" -ForegroundColor Red
    exit
}

$items = Import-Csv -Path $backupCsv
Write-Host "Restoring $($items.Count) custom assignments..." -ForegroundColor Cyan

foreach ($item in $items) {
    if ($item.Type -eq "Folder") {
        $folderPath = $item.Target
        if (Test-Path $folderPath) {
            $iniPath = Join-Path -Path $folderPath -ChildPath "desktop.ini"
            
            # Recreate or ensure desktop.ini content
            if (!(Test-Path $iniPath)) {
                $iniContent = "[.ShellClassInfo]`r`n$($item.IconSetting)"
                Set-Content -Path $iniPath -Value $iniContent -Force
            }
            
            # Apply required Windows folder attributes so Windows reads desktop.ini
            attrib +r +s "$folderPath"
            attrib +h +s "$iniPath"
            Write-Host "Restored Folder: $folderPath" -ForegroundColor DarkGray
        }
    }
    elseif ($item.Type -eq "Shortcut") {
        $shortcutPath = $item.Target
        if (Test-Path $shortcutPath) {
            $shell = New-Object -ComObject WScript.Shell
            $shortcut = $shell.CreateShortcut($shortcutPath)
            $shortcut.IconLocation = $item.IconSetting
            $shortcut.Save()
            Write-Host "Restored Shortcut: $shortcutPath" -ForegroundColor DarkGray
        }
    }
}

# Refresh Windows Explorer Icon Cache
Write-Host "Refreshing Explorer Icon Cache..." -ForegroundColor Yellow
ie4uinit.exe -show
ie4uinit.exe -ClearIconCache

Write-Host "ALL CUSTOM ICONS RESTORED!" -ForegroundColor Green