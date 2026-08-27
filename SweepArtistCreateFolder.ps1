# WHERE TO LOOK: Your current folder
$sourceDir = (Get-Location).Path
$musicVault = "C:\Users\brigi\Music\μюζικ"

$files = Get-ChildItem -Path $sourceDir -Recurse -File | Where-Object { $_.Extension -match '\.(mp3|webm)$' }

if ($null -eq $files -or $files.Count -eq 0) {
    Write-Host "No audio files found in: $sourceDir" -ForegroundColor Yellow
    return
}

$files | ForEach-Object {
    $rawArtist = $null
    
    # ULTIMATE FIX: Read the raw file bytes directly to bypass the Windows metadata bug
    if ($_.Extension -eq '.mp3') {
        try {
            $bytes = [System.IO.File]::ReadAllBytes($_.FullName)
            # Look for the standard ID3v2 "TPE1" (Lead Artist) frame inside the file data
            $encoding = [System.Text.Encoding]::ASCII
            $fileString = $encoding.GetString($bytes, 0, [Math]::Min(8192, $bytes.Length))
            $tpe1Index = $fileString.IndexOf("TPE1")
            
            if ($tpe1Index -ne -1) {
                # Grab the frame size and read the raw text bytes
                $frameSize = [System.BitConverter]::ToInt32($bytes[($tpe1Index + 7)..($tpe1Index + 4)], 0)
                if ($frameSize -gt 0 -and $frameSize -lt 200) {
                    $artistBytes = $bytes[($tpe1Index + 11)..($tpe1Index + 10 + $frameSize)]
                    # Clean out all null bytes and non-printable text characters directly from memory
                    $rawArtist = [System.Text.Encoding]::UTF8.GetString($artistBytes) -replace '[^\x20-\x7E]', ''
                    $rawArtist = $rawArtist.Trim()
                }
            }
        } catch {
            # Direct read fallback if file access is restricted
        }
    }

    # FALLBACK 1: If raw byte read fails, try using the standard shell layout
    if ([string]::IsNullOrWhiteSpace($rawArtist)) {
        $shell = New-Object -ComObject Shell.Application
        $fileFolder = $shell.NameSpace($_.DirectoryName)
        $fileItem = $fileFolder.ParseName($_.Name)
        $shellArtist = $fileFolder.GetDetailsOf($fileItem, 20)
        if ([string]::IsNullOrWhiteSpace($shellArtist)) {
            $shellArtist = $fileFolder.GetDetailsOf($fileItem, 13)
        }
        if (![string]::IsNullOrWhiteSpace($shellArtist)) {
            $rawArtist = "$shellArtist".Replace("`0", "").Trim()
        }
    }

    # FALLBACK 2: If the file has completely corrupt internal tags, split the filename by hyphen
    if ([string]::IsNullOrWhiteSpace($rawArtist) -and $_.Name -match ' - ') {
        $rawArtist = ($_.Name -split ' - ')[0].Trim()
    }

    # If we found a valid artist string, route the file
    if (![string]::IsNullOrWhiteSpace($rawArtist) -and $rawArtist.Length -gt 1) {
        # Split multiple collaborative artists
        $artistArray = $rawArtist -split '[;/]' | ForEach-Object { $_.Trim() } | Where-Object { $_ }
        $primaryArtist = $artistArray[0]
        $cleanArtist = $primaryArtist -replace '[\\/:*?"<>|]', ''
        
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
        # Catch-all safety net: if it's STILL generating a single letter, throw it to Unknown instead of breaking paths
        $targetFolder = Join-Path $musicVault "Unknown Artist"
        if (!(Test-Path $targetFolder)) { New-Item -ItemType Directory -Path $targetFolder -Force | Out-Null }
        Move-Item -LiteralPath $_.FullName -Destination (Join-Path $targetFolder $_.Name) -Force
        Write-Host "   [Tag Unreadable] Safely moved $($_.Name) to Unknown Artist vault" -ForegroundColor DarkGray
    }
}

Write-Host "Sorting complete!" -ForegroundColor Green