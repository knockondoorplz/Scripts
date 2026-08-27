$sourceDir = (Get-Location).Path
$musicVault = "C:\Users\brigi\Music\μюζικ"

$shell = New-Object -ComObject Shell.Application

Get-ChildItem -Path $sourceDir -Filter *.mp3 | ForEach-Object {
    $fileFolder = $shell.NameSpace($_.DirectoryName)
    $fileItem = $fileFolder.ParseName($_.Name)
    
    $rawArtist = $fileFolder.GetDetailsOf($fileItem, 20)
    if ([string]::IsNullOrWhiteSpace($rawArtist)) {
        $rawArtist = $fileFolder.GetDetailsOf($fileItem, 13)
    }
    
    # FALLBACK: Guess from filename if empty
    if ([string]::IsNullOrWhiteSpace($rawArtist) -and $_.Name -match ' - ') {
        $rawArtist = ($_.Name -split ' - ')[0].Trim()
    }
    
    if (![string]::IsNullOrWhiteSpace($rawArtist)) {
        # THE ULTIMATE FIX: This explicitly strips out hidden null bytes/weird string spacing
        $cleanRawArtist = [regex]::Replace($rawArtist, '[^\x20-\x7E]', '').Trim()
        
        # If it's still empty or compressed after clearing junk, fall back to safe casting
        if ([string]::IsNullOrWhiteSpace($cleanRawArtist)) {
            $cleanRawArtist = "$rawArtist".Replace("`0", "").Trim()
        }

        # Split multiple artists safely
        $artistArray = $cleanRawArtist -split '[;/]' | ForEach-Object { $_.Trim() } | Where-Object { $_ }
        
        $primaryArtist = $artistArray[0]
        $cleanArtist = $primaryArtist -replace '[\\/:*?"<>|]', ''
        
        # If the name is blank or somehow reduced to nothing, safety check to avoid root drops
        if ([string]::IsNullOrWhiteSpace($cleanArtist)) { $cleanArtist = "Unknown Artist" }

        $targetFolder = Join-Path $musicVault $cleanArtist
        
        $finalFileName = $_.Name
        if ($artistArray.Count -gt 1) {
            $featuredArtists = ($artistArray | Select-Object -Skip 1) -join ", "
            $finalFileName = "$($_.BaseName) (ft. $featuredArtists)$($_.Extension)"
        }

        if (!(Test-Path $targetFolder)) {
            New-Item -ItemType Directory -Path $targetFolder -Force | Out-Null
            Write-Host "Created folder in vault for: $cleanArtist" -ForegroundColor Magenta
        }
        
        $destination = Join-Path $targetFolder $finalFileName
        Move-Item -LiteralPath $_.FullName -Destination $destination -Force
        Write-Host "   Moved: $($_.Name) -> $targetFolder\$finalFileName" -ForegroundColor Cyan
    } else {
        Write-Host "   [No Tag] Skipping $($_.Name)" -ForegroundColor DarkGray
    }
}
Write-Host "Sorting complete!" -ForegroundColor Green