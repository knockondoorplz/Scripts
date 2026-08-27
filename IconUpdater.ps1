# Scan for desktop.ini files containing IconResource references
Get-ChildItem -Path $env:USERPROFILE -Filter "desktop.ini" -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object {
    $iniPath = $_.FullName
    $content = Get-Content -Path $iniPath -Raw -ErrorAction SilentlyContinue
    if ($content -match "IconResource|IconFile") {
        $folderPath = $_.DirectoryName
        # Extract the line specifying the icon location
        $iconLine = ($content -split "`r`n" | Where-Object { $_ -match "IconResource|IconFile" }) -join "; "
        [PSCustomObject]@{
            Folder       = $folderPath
            IniLocation  = $iniPath
            IconSetting  = $iconLine
        }
    }
} | Export-Csv -Path "$env:USERPROFILE\Desktop\CustomFolderIconsBackup.csv" -NoTypeInformation