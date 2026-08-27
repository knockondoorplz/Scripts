$SourcePath = "C:\Users\brigi\Documents\IK Multimedia\Image-Line\Data"
$DestPath = "C:\Users\brigi\Documents\Image-Line\Data"

# Get all folders in the wrong path
$Folders = Get-ChildItem -Path $SourcePath -Recurse -Directory

foreach ($Folder in $Folders) {
    # Calculate the relative path (e.g., "FL Studio\Presets\...")
    $RelPath = $Folder.FullName.Substring($SourcePath.Length + 1)
    $TargetDir = Join-Path $DestPath $RelPath

    # Ensure the directory exists in the destination
    if (!(Test-Path $TargetDir)) {
        Write-Host "Creating structure: $RelPath" -ForegroundColor Cyan
        New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
    }

    # Move files from IK folder to Correct folder
    $Files = Get-ChildItem -Path $Folder.FullName -File
    foreach ($File in $Files) {
        $DestFile = Join-Path $TargetDir $File.Name
        
        if (Test-Path $DestFile) {
            $SourceDate = (Get-Item $File.FullName).LastWriteTime
            $DestDate = (Get-Item $DestFile).LastWriteTime
            
            if ($SourceDate -gt $DestDate) {
                Write-Host "Updating file: $($File.Name)" -ForegroundColor Yellow
                Move-Item -Path $File.FullName -Destination $DestFile -Force
            }
        } else {
            Write-Host "Migrating: $($File.Name)" -ForegroundColor Green
            Move-Item -Path $File.FullName -Destination $DestFile -Force
        }
    }
}