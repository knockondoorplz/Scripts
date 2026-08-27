# RestoreShortcuts.ps1 - Bulk Restore Shortcut (.lnk) Icons from CSV
$backupCsv = "$env:USERPROFILE\Desktop\New Folder\IconTest\CustomShortcutIconsBackup.csv"

if (!(Test-Path $backupCsv)) {
    Write-Host "Error: Cannot find $backupCsv on your Desktop!" -ForegroundColor Red
    exit
}

$shortcuts = Import-Csv -Path $backupCsv
$shell = New-Object -ComObject WScript.Shell

foreach ($item in $shortcuts) {
    # Reconstruct target path if name was saved
    $shortcutPath = Join-Path "$env:USERPROFILE\Desktop" $item.Name
    
    if (Test-Path $shortcutPath) {
        $shortcut = $shell.CreateShortcut($shortcutPath)
        $shortcut.IconLocation = $item.IconLocation
        $shortcut.Save()
        Write-Host "Restored Shortcut: $($item.Name)" -ForegroundColor Green
    } else {
        Write-Host "Shortcut not found on Desktop: $($item.Name)" -ForegroundColor Yellow
    }
}

# Force Explorer to refresh icons
ie4uinit.exe -show
ie4uinit.exe -ClearIconCache

Write-Host "ALL SHORTCUT ICONS RESTORED!" -ForegroundColor Cyan