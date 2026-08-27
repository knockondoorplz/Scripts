Get-ChildItem *.mp3 | ForEach-Object {
    if ($_.Name.Length -gt 6) {
        $newName = $_.Name.Substring(3)
        Rename-Item -Path $_.FullName -NewName $newName
    }
}