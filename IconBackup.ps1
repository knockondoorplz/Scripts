# IconBackup.ps1 - Fast Snapshot of Custom Folders & Shortcuts
$backupCsv = "$env:USERPROFILE\Desktop\CustomIconsBackup.csv"
$results = [System.Collections.Generic.List[PSObject]]::new()

Write-Host "Scanning for custom folder icons..." -ForegroundColor Cyan

# 1. Scan Folders for desktop.ini containing custom icon paths
Get-ChildItem -Path $env:USERPROFILE -Filter "desktop.ini" -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object {
    $iniContent = Get-Content -Path $_.FullName -Raw -ErrorAction SilentlyContinue
    if ($iniContent -match "IconResource|IconFile") {
        # Extract the icon path line
        $iconLine = ($iniContent -split "`r`n" | Where-Object { $_ -match "IconResource|IconFile" }) -join "; "
        $results.Add([PSCustomObject]@{
            Type        = "Folder"
            Target      = $_.DirectoryName
            IconSetting = $iconLine
        })
    }
}

Write-Host "Scanning for customized shortcuts..." -ForegroundColor Cyan

# 2. Scan Desktop and Start Menu for shortcuts (.lnk) with custom icons
$shortcutPaths = @("$env:USERPROFILE\Desktop", "$env:APPDATA\Microsoft\Windows\Start Menu")
Get-ChildItem -Path $shortcutPaths -Filter "*.lnk" -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut($_.FullName)
    if ($shortcut.IconLocation -and $shortcut.IconLocation -notlike ",0") {
        $results.Add([PSCustomObject]@{
            Type        = "Shortcut"
            Target      = $_.FullName
            IconSetting = $shortcut.IconLocation
        })
    }
}

$results | Export-Csv -Path $backupCsv -NoTypeInformation
Write-Host "DONE! Snapshot saved to: $backupCsv" -ForegroundColor Green