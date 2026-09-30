$shell = New-Object -ComObject WScript.Shell

Get-ChildItem *.lnk | ForEach-Object {
    $s = $shell.CreateShortcut($_.FullName)
    [PSCustomObject]@{
        name = $_.BaseName
        path = $s.TargetPath
    }
} | ConvertTo-Json -Depth 3 | Set-Content .\locations.json