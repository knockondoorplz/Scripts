# --- MASTER PATHS ---
$CorrectPath = "C:\Users\brigi\Documents\Image-Line\Data\FL Studio"
$WrongPath   = "C:\Users\brigi\Documents\IK Multimedia\Image-Line\Data\FL Studio"

function Audit-And-Merge {
    param($Source, $Destination)

    # Get all subdirectories
    $Folders = Get-ChildItem -Path $Source -Recurse -Directory

    foreach ($Folder in $Folders) {
        $RelPath = $Folder.FullName.Substring($Source.Length + 1)
        $DestFolder = Join-Path $Destination $RelPath

        # Audit: If destination doesn't exist, just move it
        if (!(Test-Path $DestFolder)) {
            Write-Host "Creating missing folder structure: $RelPath" -ForegroundColor Cyan
            New-Item -ItemType Directory -Path $DestFolder -Force | Out-Null
        }

        # Sync files in this folder
        $Files = Get-ChildItem -Path $Folder.FullName -File
        foreach ($File in $Files) {
            $TargetFile = Join-Path $DestFolder $File.Name
            
            if (Test-Path $TargetFile) {
                # Compare by date: keep the newest
                $SourceDate = (Get-Item $File.FullName).LastWriteTime
                $DestDate   = (Get-Item $TargetFile).LastWriteTime

                if ($SourceDate -gt $DestDate) {
                    Write-Host "Updating newer version: $($File.Name)" -ForegroundColor Yellow
                    Move-Item -Path $File.FullName -Destination $TargetFile -Force
                }
            } else {
                # File missing in destination: move it
                Write-Host "Migrating unique file: $($File.Name)" -ForegroundColor Green
                Move-Item -Path $File.FullName -Destination $TargetFile -Force
            }
        }
    }
}

# Run the Audit
Write-Host "Auditing structures..." -ForegroundColor Magenta
Audit-And-Merge -Source $WrongPath -Destination $CorrectPath
Write-Host "Sync complete. All folders merged into Master directory." -ForegroundColor Green