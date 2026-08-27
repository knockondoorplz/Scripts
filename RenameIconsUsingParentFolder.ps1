$root = "C:\Users\brigi\Documents\Jason\Rainmeter\Skins"

Get-ChildItem -Path $root -Recurse -Filter *.png | ForEach-Object {
    $parentFolder = Split-Path $_.DirectoryName -Leaf
    $extension = $_.Extension
    $number = $_.BaseName  # this is "1" or "2" etc.

    $newName = "$parentFolder $number$extension"

    # Only rename if the name is different
    if ($_.Name -ne $newName) {
        Rename-Item -Path $_.FullName -NewName $newName -Force
    }
}
