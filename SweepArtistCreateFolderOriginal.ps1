# Target folder with the messy files
$sourceDir = "C:\Users\brigi\Desktop\New folder"

# Load the Windows Shell application to read metadata tags
$shell = New-Object -ComObject Shell.Application

# Grab all MP3 files in the source directory
Get-ChildItem -Path $sourceDir -Filter *.mp3 | ForEach-Object {
    $fileFolder = $shell.NameSpace($_.DirectoryName)
    $fileItem = $fileFolder.ParseName($_.Name)
    
    # Extended Property 20 is usually "Contributing artists" in Windows
    $artist = $fileFolder.GetDetailsOf($fileItem, 20)
    
    # Fallback check if index 20 is empty (sometimes it's index 13)
    if ([string]::IsNullOrWhiteSpace($artist)) {
        $artist = $fileFolder.GetDetailsOf($fileItem, 13)
    }
    
    # Clean up the artist string (remove illegal folder characters like /, \, :, *, ?, ", <, >, |)
    $cleanArtist = $artist -replace '[\\/:*?"<>|]', '' -replace '^\s+|\s+$', ''

    # If an artist tag exists, move the file!
    if (![string]::IsNullOrWhiteSpace($cleanArtist)) {
        $targetFolder = Join-Path $sourceDir $cleanArtist
        
        # Create the artist folder if it doesn't exist yet
        if (!(Test-Path $targetFolder)) {
            New-Item -ItemType Directory -Path $targetFolder -Force | Out-Null
            Write-Host "Created new folder for: $cleanArtist" -ForegroundColor Magenta
        }
        
        # Move the MP3 into its new home
        $destination = Join-Path $targetFolder $_.Name
        if (!(Test-Path $destination)) {
            Move-Item -Path $_.FullName -Destination $destination -Force
            Write-Host "   Moved: $($_.Name) -> $cleanArtist/" -ForegroundColor Cyan
        } else {
            Write-Host "   [Skip] $($_.Name) already exists in $cleanArtist/" -ForegroundColor Yellow
        }
    } else {
        Write-Host "   [No Tag] Skipping $($_.Name) (No Artist metadata found)" -ForegroundColor DarkGray
    }
}

Write-Host "Sorting complete!" -ForegroundColor Green