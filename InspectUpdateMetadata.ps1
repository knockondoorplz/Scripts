# Set your target music root folder path
$MusicPath = "C:\Users\YourUsername\Music"

$shell = New-Object -ComObject Shell.Application

Get-ChildItem -Path $MusicPath -Recurse -File | ForEach-Object {
    $folderPath = $_.DirectoryName
    $parentFolder = Split-Path $folderPath -Leaf          # Subfolder (Album)
    $grandparentPath = Split-Path $folderPath -Parent
    $artistFolder = Split-Path $grandparentPath -Leaf      # Parent/Roof folder (Artist)

    # Use Shell.Application to access Windows Extended File Properties
    $shellFolder = $shell.NameSpace($_.DirectoryName)
    $shellFile = $shellFolder.ParseName($_.Name)

    # Note: Direct writing to ID3 metadata via Shell.Application can depend on OS codec support.
    # For bulk renaming/restructuring files to match the Parent\Subfolder layout:
    Write-Host "File: $($_.Name) | Derived Artist: $artistFolder | Derived Album: $parentFolder"
}