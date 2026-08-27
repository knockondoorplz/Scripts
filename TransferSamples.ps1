# --- DEFINE YOUR CORRECT PATHS ---
$UserName = $env:USERNAME
$TrueFL25UserPath = "C:\Users\$UserName\AppData\Roaming\Image-Line"
$FL25SharedPacks  = "C:\Users\$UserName\Documents\Image-Line\FL Studio\Presets\Packs"

# Stranded paths to rescue
$AccidentalIKPath = "C:\Users\$UserName\Documents\IK Multimedia\Image-Line\data"
$OldFL21Packs     = "C:\Program Files\Image-Line\FL Studio 21\Data\Patches\Packs"
$OldFL24Packs     = "C:\Program Files\Image-Line\FL Studio 2024\Data\Patches\Packs"

# --- FUNCTION TO SAFELY MERGE FOLDERS WITH OVERWRITE PROMPTS ---
function Merge-Folders ($Source, $Destination) {
    if (Test-Path $Source) {
        Get-ChildItem -Path $Source -Recurse | Where-Object { !$_.PSIsContainer } | ForEach-Object {
            $TargetFile = $_.FullName.Replace($Source, $Destination)
            $TargetDir  = Split-Path $TargetFile
            if (!(Test-Path $TargetDir)) { New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null }
            
            if (Test-Path $TargetFile) {
                # Prompt before overwriting existing files
                Move-Item -Path $_.FullName -Destination $TargetFile -Confirm:$true -Force
            } else {
                Move-Item -Path $_.FullName -Destination $TargetFile -Force
            }
        }
        Write-Host "Successfully merged $Source into $Destination" -ForegroundColor Green
    } else {
        Write-Host "Source path not found (skipping): $Source" -ForegroundColor Yellow
    }
}

# --- RUN THE CONSOLIDATION ---
Write-Host "Starting FL Studio 25 Vault Consolidation..." -ForegroundColor Cyan

# 1. Rescue the presets and projects from the IK Multimedia accident
Merge-Folders -Source $AccidentalIKPath -Destination "$TrueFL25UserPath\FL Studio"

# 2. Consolidate your 226,000 samples from FL 21 / 24 Packs into FL 25 Packs
Merge-Folders -Source $OldFL21Packs -Destination $FL25SharedPacks
Merge-Folders -Source $OldFL24Packs -Destination $FL25SharedPacks

Write-Host "Consolidation complete! Your files are safely staged for FL Studio 25." -ForegroundColor Green