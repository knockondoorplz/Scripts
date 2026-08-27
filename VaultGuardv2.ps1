# VaultGuardv2.ps1
$VaultPath = "H:\Jason's Files\!NTY1T10XYZ"
$ShadowPath = "$VaultPath\.vault_shadow"
$LogPath = "$VaultPath\.trash\VaultGuard_Restores.log"

if (!(Test-Path $ShadowPath)) { New-Item -ItemType Directory -Force -Path $ShadowPath | Out-Null }

$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $VaultPath
$watcher.Filter = "*.md"
$watcher.IncludeSubdirectories = $true
$watcher.EnableRaisingEvents = $true

$fileSizes = @{}

$action = {
    $path = $Event.SourceEventArgs.FullPath
    if ($path -like "*\.git\*" -or $path -like "*\.trash\*" -or $path -like "*\.vault_shadow\*") { return }

    $file = Get-Item $path -ErrorAction SilentlyContinue
    $relativePath = $path.Substring($VaultPath.Length).TrimStart('\')
    $shadowFile = Join-Path $ShadowPath $relativePath

    # CASE 1: File Deletion or Violent Truncation
    if (-not $file -or ($fileSizes[$path] -and $file.Length / $fileSizes[$path] -lt 0.20 -and $fileSizes[$path] -gt 1000)) {
        if (Test-Path $shadowFile) {
            $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            Add-Content -Path $LogPath -Value "[$timestamp] RESTORED FILE: $path"
            
            # Immediately restore from Shadow Cache
            $shadowDir = Split-Path $path -Parent
            if (!(Test-Path $shadowDir)) { New-Item -ItemType Directory -Force -Path $shadowDir | Out-Null }
            Copy-Item -Path $shadowFile -Destination $path -Force
            
            [reflection.assembly]::loadwithpartialname("System.Windows.Forms")
            [System.Windows.Forms.MessageBox]::Show("VaultGuard auto-restored:`n$relativePath", "Accident Prevention Triggered", 0, 48)
            return
        }
    }

    # CASE 2: Valid Edit -> Update Shadow Cache
    if ($file -and $file.Length -gt 200) {
        $fileSizes[$path] = $file.Length
        $shadowDir = Split-Path $shadowFile -Parent
        if (!(Test-Path $shadowDir)) { New-Item -ItemType Directory -Force -Path $shadowDir | Out-Null }
        Copy-Item -Path $path -Destination $shadowFile -Force
    }
}

Register-ObjectEvent $watcher "Changed" -Action $action
Register-ObjectEvent $watcher "Deleted" -Action $action
while ($true) { Start-Sleep -Seconds 2 }