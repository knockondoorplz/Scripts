$root = "C:\Users\brigi\Desktop\New folder\Rainmeter Icons"

Get-ChildItem -Path $root -Recurse -Filter *.png | ForEach-Object {
    # Get relative path after $root to isolate the top-level subfolder
    $relativePath = $_.FullName.Substring($root.Length).TrimStart('\')
    $pathParts = $relativePath -split '\\'

    # Ensure the file is actually inside a subfolder, not sitting in $root directly
    if ($pathParts.Count -gt 1) {
        $skinFolder = $pathParts[0]
        
        # Extract first word (split on space or hyphen)
        $firstWord = $skinFolder -split '[\s-]' | Select-Object -First 1

        $originalName = $_.Name
        $newName = "$firstWord $originalName"

        # Prevent prepending multiple times if already renamed
        if (-not $_.Name.StartsWith($firstWord)) {
            Rename-Item -Path $_.FullName -NewName $newName -Force
            Write-Host "Renamed: '$originalName' -> '$newName'" -ForegroundColor Green
        }
    }
}