Get-ChildItem "C:\Users\brigi\Music\μюζικ\Audeka\Engine Block" -Filter *.mp4 | ForEach-Object {
    $output = "$($_.DirectoryName)\$($_.BaseName).mp3"
    ffmpeg -i $_.FullName -map a -q:a 0 $output
}