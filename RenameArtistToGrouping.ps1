# Connect to running iTunes application
$itunes = New-Object -ComObject iTunes.Application
$tracks = $itunes.SelectedTracks

if ($null -eq $tracks -or $tracks.Count -eq 0) {
    Write-Host "No tracks selected! Please select the tracks in iTunes first." -ForegroundColor Red
    exit
}

Write-Host "Processing $($tracks.Count) tracks in iTunes..." -ForegroundColor Green

foreach ($track in $tracks) {
    $currentArtist = $track.Artist
    $currentTitle  = $track.Name
    
    # List of YouTube channels/labels to strip from Artist and move to Publisher/Comments
    $labels = @("Dubstep uNk", "The Dub Rebellion", "Disciple", "UKF", "Subsidia", "Never Say Die")
    
    $foundLabel = ""
    foreach ($label in $labels) {
        if ($currentArtist -like "*$label*") {
            $foundLabel = $label
            break
        }
    }

    # 1. If a channel/label is found in the Artist tag, move it to Publisher (Grouping/Comments)
    if ($foundLabel -ne "") {
        $track.Grouping = $foundLabel  # Stores Label/Publisher info in iTunes
        $track.Comment  = "Release via $foundLabel"
        
        # Clean the label out of the Artist string
        $currentArtist = $currentArtist -ireplace [regex]::Escape($foundLabel), ""
        $currentArtist = $currentArtist.Trim(" -|/[]()")
    }

    # 2. Extract featured artists from Artist field and append to Title
    if ($currentArtist -match "(?i)(.*?)\s+(?:ft\.|feat\.|featuring)\s+(.*)") {
        $mainArtist  = $matches[1].Trim()
        $featured    = $matches[2].Trim()
        
        # Update Title with featured artist if not already there
        if ($currentTitle -notlike "*(ft. $featured)*") {
            $track.Name = "$currentTitle (ft. $featured)"
        }
        $track.Artist = $mainArtist
    } else {
        # If no feature, assign cleaned artist name
        if (-not [string]::IsNullOrWhiteSpace($currentArtist)) {
            $track.Artist = $currentArtist
        }
    }

    # 3. Ensure Album Artist matches primary root artist
    if ($track.Artist -ne "") {
        $track.AlbumArtist = "Code: Pandorum"
    }

    Write-Host "Updated: $($track.Name) | Artist: $($track.Artist) | Label: $($track.Grouping)"
}

Write-Host "Finished updating iTunes metadata!" -ForegroundColor Cyan