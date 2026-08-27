# Get EVERY single subdirectory down the entire tree recursively
Get-ChildItem -Directory -Recurse | Sort-Object FullName -Descending | ForEach-Object {
    
    # Change into the target folder
    Push-Location $_.FullName
    
    # 1. Grab all WebM and MP3 files in this specific folder
    $files = Get-ChildItem -File | Where-Object { $_.Extension -match '\.(webm|mp3)$' }
    
    if ($files.Count -eq 0) {
        Pop-Location
        return # Skip folder if it has no music/video files
    }

    # 2. INTEL CHECK: Count how many files start with a number pattern
    $pattern = '^\d+[\s\-\.]*'
    $matchCount = ($files | Where-Object { $_.BaseName -match $pattern }).Count
    
    # Decision: Only strip numbers if MORE THAN HALF the files in this specific folder have track numbers
    $shouldStripNumbers = $matchCount -gt ($files.Count / 2)
    
    if ($shouldStripNumbers) {
        Write-Host "`nProcessing Folder (Tracklist Detected): $($_.FullName)" -ForegroundColor Green
    } else {
        Write-Host "`nProcessing Folder (Standard Titles): $($_.FullName)" -ForegroundColor DarkGreen
    }

    # 3. Process the files
    $files | ForEach-Object {
        $currentName = $_.Name
        $oldExtension = $_.Extension
        $baseName = $_.BaseName
        
        # Determine the clean base name based on our folder-wide decision
        if ($shouldStripNumbers -and ($baseName -match $pattern)) {
            $cleanBaseName = $baseName -replace $pattern, ''
        } else {
            $cleanBaseName = $baseName
        }

        # 4. Handle WebM Files (Convert + Clean Name)
        if ($oldExtension -eq '.webm') {
            $outputName = "$cleanBaseName.mp3"
            Write-Host "   Converting: $currentName -> $outputName" -ForegroundColor Cyan
            
            # Run FFmpeg conversion
            ffmpeg -i $_.FullName -vn -ab 192k -ar 44100 "$outputName" -y -loglevel quiet
            
            # Delete the original WebM file after successful conversion
            if ($LASTEXITCODE -eq 0) {
                Remove-Item $_.FullName
            } else {
                Write-Host "   [ERROR] Failed to convert $currentName" -ForegroundColor Red
            }
        } 
        # 5. Handle Existing MP3 Files (Just Rename)
        elseif ($oldExtension -eq '.mp3') {
            $outputName = "$cleanBaseName.mp3"
            if ($currentName -ne $outputName) {
                Write-Host "   Renaming MP3: $currentName -> $outputName" -ForegroundColor Yellow
                Rename-Item -Path $_.FullName -NewName $outputName
            }
        }
    }

    # Go back to the parent folder
    Pop-Location
}