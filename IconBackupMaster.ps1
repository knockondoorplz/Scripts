# IconBackupMaster.ps1 - Unified System-Wide Icon Backup
$backupCsv = "$env:USERPROFILE\Desktop\MasterIconBackup.csv"
$results = [System.Collections.Generic.List[PSObject]]::new()

Write-Host "1/2 Scanning C:\Users\brigi for custom folder icons..." -ForegroundColor Cyan

# 1. Scan Folders for desktop.ini files
Get-ChildItem -Path $env:USERPROFILE -Filter "desktop.ini" -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object {
    $iniContent = Get-Content -Path $_.FullName -Raw -ErrorAction SilentlyContinue
    if ($iniContent -match "IconResource|IconFile") {
        # Clean up and grab the icon assignment line
        $iconLine = ($iniContent -split "`r`n" | Where-Object { $_ -match "IconResource|IconFile" }) -join "; "
        $results.Add([PSCustomObject]@{
            Type        = "Folder"
            Target      = $_.DirectoryName
            IconSetting = $iconLine
        })
    }
}

Write-Host "2/2 Scanning C:\Users\brigi for custom shortcuts (.lnk)..." -ForegroundColor Cyan

# 2. Scan entire profile for .lnk files with custom icons
$shell = New-Object -ComObject WScript.Shell
Get-ChildItem -Path $env:USERPROFILE -Filter "*.lnk" -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
    $shortcut = $shell.CreateShortcut($_.FullName)
    # Check if shortcut points to a custom icon (ignoring standard index 0 defaults)
    if ($shortcut.IconLocation -and $shortcut.IconLocation -notlike ",0") {
        $results.Add([PSCustomObject]@{
            Type        = "Shortcut"
            Target      = $_.FullName
            IconSetting = $shortcut.IconLocation
        })
    }
}

$results | Export-Csv -Path $backupCsv -NoTypeInformation
Write-Host "SUCCESS! Master snapshot saved to: $backupCsv" -ForegroundColor Green