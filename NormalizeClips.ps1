<#
.SYNOPSIS
  Batch-normalizes a folder of mixed clips/GIFs (from Pinterest, etc.)
  into uniform, silent, looping .mp4 files ready for WallpaperPlayer.ahk.

.USAGE
  1. Put your downloaded gifs/mp4s/webms/movs into $InputDir
  2. Edit $Width / $Height to match your monitor resolution
  3. Run: powershell -ExecutionPolicy Bypass -File NormalizeClips.ps1
  4. Normalized clips land in $OutputDir — point WallpaperPlayer.ahk's
     clipsDir at that folder.

  Requires ffmpeg on PATH (https://ffmpeg.org/download.html — the
  "essentials" build from gyan.dev is the easiest on Windows).
#>

# ---------------- CONFIG ----------------
$InputDir  = "C:\Users\brigi\Videos\Anim"
$OutputDir = "C:\Users\brigi\Videos\Anim\Clips"
$Width     = 1366
$Height    = 768
$Fps       = 30
$Crf       = 20          # lower = higher quality/bigger file, 18-23 is a sane range
# -----------------------------------------

if (-not (Get-Command ffmpeg -ErrorAction SilentlyContinue)) {
    Write-Error "ffmpeg not found on PATH. Install it and restart your terminal."
    exit 1
}

if (-not (Test-Path $InputDir)) {
    Write-Error "Input folder does not exist: $InputDir"
    exit 1
}

New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

$extensions = @("*.mp4","*.mov","*.mkv","*.webm","*.gif","*.avi")
$files = Get-ChildItem -Path $InputDir -Include $extensions -File -Recurse

if ($files.Count -eq 0) {
    Write-Warning "No matching video/gif files found in $InputDir"
    exit 0
}

$i = 0
foreach ($file in $files) {
    $i++
    $outName = "clip_{0:D3}.mp4" -f $i
    $outPath = Join-Path $OutputDir $outName

    Write-Host "[$i/$($files.Count)] Normalizing: $($file.Name) -> $outName"

    # scale to cover target res, center-crop to exact size, strip audio,
    # force constant fps, encode as widely-compatible H.264
    $vf = "scale=${Width}:${Height}:force_original_aspect_ratio=increase,crop=${Width}:${Height},fps=${Fps},format=yuv420p"

    & ffmpeg -y -i "$($file.FullName)" `
        -vf $vf `
        -an `
        -c:v libx264 -preset veryfast -crf $Crf `
        -movflags +faststart `
        "$outPath" 2>$null

    if ($LASTEXITCODE -ne 0) {
        Write-Warning "  Failed on $($file.Name) — skipping"
    }
}

Write-Host "`nDone. $($files.Count) clips processed into $OutputDir"
