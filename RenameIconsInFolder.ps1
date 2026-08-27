$folder = "C:\Users\brigi\Desktop\New folder\Rainmeter Icons\swtor-republic\DUI - Republic\Weather"
$prefix = "Weather"

$files = Get-ChildItem -Path $folder -Filter *.png | Sort-Object Name

$i = 1
foreach ($file in $files) {
    $newName = "$prefix $i.png"
    Rename-Item -Path $file.FullName -NewName $newName -Force
    $i++
}

