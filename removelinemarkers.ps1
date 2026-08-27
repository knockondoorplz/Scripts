Get-ChildItem *.md | ForEach-Object {
    (Get-Content $_) -replace '\\$','' | Set-Content $_
}