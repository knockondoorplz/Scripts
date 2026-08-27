$root = "C:\Users\brigi\Documents\Rainmeter
Skins"

Get-ChildItem -Path $root -Recurse -Filter *.png | ForEach-Object {

    # Find the top-level skin folder (the one directly under Skins)
    $current = $_.Directory
    while ($current.Parent -and $current.Parent.Name -ne "Skins") {
        $current = $current.Parent
    }

    # Extract only the first word (split on space or hyphen)
    $skinFolder = $current.Name
    $firstWord = $skinFolder -split '[\s-]' | Select-Object -First 1

    # Original filename
    $originalName = $_.Name

    # New name: FirstWord + space + original filename
    $newName = "$firstWord $originalName"

    if ($_.Name -ne $newName) {
        Rename-Item -Path $_.FullName -NewName $newName -Force
    }
}
