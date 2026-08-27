Get-ChildItem *.rtf | ForEach-Object {
 "C:\Program Files\Pandoc\pandoc.exe" $_ -t gfm -o "$($_.BaseName).md"
}