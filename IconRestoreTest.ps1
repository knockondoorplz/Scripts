# Restore-SingleFolder.ps1 - Test restore on just one target folder
param (
    [Parameter(Mandatory=$true)]
    [string]$TargetFolder
)

$backupCsv = "$env:USERPROFILE\Desktop\\CustomIconsBackup.csv"

if (!(Test-Path $backupCsv)) {
    Write-Host "Error: Cannot find $backupCsv on your Desktop!" -ForegroundColor Red
    exit
}

# Search CSV for matching folder path (case-insensitive)
$item = Import-Csv -Path $backupCsv | Where-Object { $_.Target -eq $TargetFolder -and $_.Type -eq "Folder" }

if (!$item) {
    Write-Host "No backup entry found for: $TargetFolder" -ForegroundColor Yellow
    exit
}

$iniPath = Join-Path -Path $TargetFolder -ChildPath "desktop.ini"

# Re-create desktop.ini
$iniContent = "[.ShellClassInfo]`r`n$($item.IconSetting)"
Set-Content -Path $iniPath -Value $iniContent -Force

# Apply required attributes
attrib +r +s "$TargetFolder"
attrib +h +s "$iniPath"

# Refresh Explorer
ie4uinit.exe -show
ie4uinit.exe -ClearIconCache

Write-Host "SUCCESS! Restored icon for: $TargetFolder" -ForegroundColor Green