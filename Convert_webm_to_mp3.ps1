Get-ChildItem *.webm | ForEach-Object {
    $outputName = $_.BaseName + ".mp3"
    ffmpeg -i $_.FullName -vn -ab 192k -ar 44100 "$outputName"
}