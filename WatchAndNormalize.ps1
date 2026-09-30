<#
.SYNOPSIS
  Watches RawDir for newly added video/gif files, normalizes each one
  with ffmpeg into ClipsDir, and (if the wallpaper is currently running)
  pushes it straight into mpv's live playlist over IPC - no restart.

  Event-driven (FileSystemWatcher), not polling - idle cost is ~0 until
  a file actually shows up. Runs continuously in the background,
  independent of whether wallpaper playback is currently on or off.

.USAGE
  Normally launched automatically by WallpaperPlayer.ahk. Can also be run
  standalone:
    powershell -ExecutionPolicy Bypass -File .\WatchAndNormalize.ps1
#>

param(
    [string]$RawDir    = "C:\Users\brigi\Videos\Anim\Raw",
    [string]$ClipsDir  = "C:\Users\brigi\Videos\Anim\Clips",
    [int]$Width        = 1920,
    [int]$Height       = 1080,
    [int]$Fps          = 30,
    [int]$Crf          = 20,
    [string]$PipeName  = "mpv-wallpaper"
)

if (-not (Get-Command ffmpeg -ErrorAction SilentlyContinue)) {
    Write-Error "ffmpeg not found on PATH."
    exit 1
}

New-Item -ItemType Directory -Force -Path $RawDir | Out-Null
New-Item -ItemType Directory -Force -Path $ClipsDir | Out-Null

$script:RawDir = $RawDir
$script:ClipsDir = $ClipsDir
$script:Width = $Width
$script:Height = $Height
$script:Fps = $Fps
$script:Crf = $Crf
$script:PipeName = $PipeName
$script:extensions = @(".mp4", ".mov", ".mkv", ".webm", ".gif", ".avi")

function Get-SafeOutputName {
    param($file)
    $base = [IO.Path]::GetFileNameWithoutExtension($file.Name)
    $safe = ($base -replace '[^\w\-]', '_')
    return "$safe.mp4"
}

function Wait-ForFileReady {
    param($path, $maxTries = 15)
    for ($i = 0; $i -lt $maxTries; $i++) {
        try {
            $stream = [IO.File]::Open($path, 'Open', 'Read', 'None')
            $stream.Close()
            return $true
        } catch {
            Start-Sleep -Milliseconds 800
        }
    }
    return $false
}

function Normalize-Clip {
    param($file)

    $outName = Get-SafeOutputName $file
    $outPath = Join-Path $script:ClipsDir $outName

    if (Test-Path $outPath) { return $null }

    if (-not (Wait-ForFileReady $file.FullName)) {
        Write-Warning "Timed out waiting for file to finish writing: $($file.Name)"
        return $null
    }

    Write-Host "Normalizing: $($file.Name) -> $outName"
    $vf = "scale=$($script:Width):$($script:Height):force_original_aspect_ratio=increase,crop=$($script:Width):$($script:Height),fps=$($script:Fps),format=yuv420p"

    ffmpeg -y -i $file.FullName -vf $vf -an -c:v libx264 -preset veryfast -crf $script:Crf -movflags +faststart $outPath 2>$null

    if ($LASTEXITCODE -ne 0) {
        Write-Warning "ffmpeg failed on $($file.Name)"
        return $null
    }
    return $outPath
}

function Notify-Mpv {
    param($clipPath)
    try {
        $pipe = New-Object System.IO.Pipes.NamedPipeClientStream(".", $script:PipeName, [System.IO.Pipes.PipeDirection]::Out)
        $pipe.Connect(500)
        $writer = New-Object System.IO.StreamWriter($pipe)
        $writer.AutoFlush = $true
        $escaped = $clipPath.Replace('\', '\\').Replace('"', '\"')
        $loadCmd = '{"command": ["loadfile", "' + $escaped + '", "append"]}'
        $shuffleCmd = '{"command": ["playlist-shuffle"]}'
        $writer.WriteLine($loadCmd)
        $writer.WriteLine($shuffleCmd)
        $writer.Close()
        $pipe.Close()
    } catch {
        # mpv isn't running right now, or the pipe isn't available - that's fine.
        # The clip is already normalized and will be picked up next time playback starts.
    }
}

# ---- Initial catch-up pass: normalize anything already sitting in Raw ----
Get-ChildItem -Path $script:RawDir -File | Where-Object { $script:extensions -contains $_.Extension.ToLower() } | ForEach-Object {
    $result = Normalize-Clip $_
    if ($result) { Notify-Mpv $result }
}

# ---- Live watch for anything dropped in afterward ----
$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $script:RawDir
$watcher.IncludeSubdirectories = $false
$watcher.EnableRaisingEvents = $true

$action = {
    $path = $Event.SourceEventArgs.FullPath
    $ext = [IO.Path]::GetExtension($path).ToLower()
    if ($script:extensions -contains $ext) {
        $file = Get-Item -Path $path -ErrorAction SilentlyContinue
        if ($file) {
            $result = Normalize-Clip $file
            if ($result) { Notify-Mpv $result }
        }
    }
}

Register-ObjectEvent -InputObject $watcher -EventName Created -Action $action | Out-Null
Register-ObjectEvent -InputObject $watcher -EventName Renamed -Action $action | Out-Null

Write-Host "Watching $($script:RawDir) for new clips..."
while ($true) { Start-Sleep -Seconds 3600 }
