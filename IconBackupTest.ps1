Get-ChildItem -Path "$env:USERPROFILE\Desktop\New Folder\IconTest" -Filter "desktop.ini" -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object {
    $iniContent = Get-Content -Path $_.FullName -Raw -ErrorAction SilentlyContinue
    if ($iniContent -match "IconResource|IconFile") {
        [PSCustomObject]@{
            Folder      = $_.DirectoryName
            IconSetting = ($iniContent -split "`r`n" | Where-Object { $_ -match "IconResource|IconFile" })
        }
    }
}