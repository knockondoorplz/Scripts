# 1. Scan Desktop for Shortcuts (.lnk) with custom icons
Get-ChildItem -Recurse -Path "$env:USERPROFILE" -Filter "*.lnk" | ForEach-Object {
    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut($_.FullName)
    if ($shortcut.IconLocation -and $shortcut.IconLocation -notlike ",0") {
        [PSCustomObject]@{
            Name         = $_.Name
            Type         = "Shortcut (.lnk)"
            IconLocation = $shortcut.IconLocation
        }
    }
}