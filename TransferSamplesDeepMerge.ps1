# --- PATH DEFINITIONS ---
$SourcePath = "C:\Users\brigi\Documents\IK Multimedia\Image-Line\Data\FL Studio\Presets"
$DestPath   = "C:\Users\brigi\Documents\Image-Line\Data\FL Studio\Presets"

# --- THE MERGE LOGIC ---
function Merge-Presets {
    param([string]$Source, [string]$Destination)

    # Get all files from the source recursively
    $Files = Get-ChildItem -Path $Source -Recurse -File

    foreach ($File in $Files) {
        # Determine the relative path to maintain the folder structure
        $RelativePath = $File.FullName.Substring($Source.Length + 1)
        $TargetFile = Join-Path $Destination $RelativePath
        
        # Ensure the destination subdirectory exists
        $TargetFolder = Split-Path $TargetFile
        if (!(Test-Path $TargetFolder)) {
            New-Item -ItemType Directory -Path $TargetFolder -Force | Out-Null
        }

        # If file exists in destination, check if we should overwrite
        if (Test-Path $TargetFile) {
            Write-Host "Conflict: $RelativePath already exists." -ForegroundColor Yellow
            $choice = Read-Host "Overwrite? (y = Yes, n = Skip, a = All)"
            if ($choice -eq 'y' -or $choice -eq 'a') {
                Move-Item -Path $File.FullName -Destination $TargetFile -Force
            }
        } else {
            # Move if it doesn't exist
            Write-Host "Moving: $RelativePath" -ForegroundColor Green
            Move-Item -Path $File.FullName -Destination $TargetFile -Force
        }
    }
}

# --- EXECUTE ---
if (Test-Path $SourcePath) {
    Merge-Presets -Source $SourcePath -Destination $DestPath
    Write-Host "Merge complete. Your presets are now consolidated." -ForegroundColor Cyan
} else {
    Write-Host "Source path not found. Check your IK Multimedia path." -ForegroundColor Red
}