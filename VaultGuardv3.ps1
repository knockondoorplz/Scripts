# VaultGuardv2.ps1 - Bulletproof Immortal Vault Guard
$VaultPath = "H:\Jason's Files\!NTY1T10XYZ"
$ShadowPath = "$VaultPath\.vault_shadow"
$LogPath = "$VaultPath\.trash\VaultGuard_Restores.log"

if (!(Test-Path $ShadowPath)) { New-Item -ItemType Directory -Force -Path $ShadowPath | Out-Null }
if (!(Test-Path (Split-Path $LogPath))) { New-Item -ItemType Directory -Force -Path (Split-Path $LogPath) | Out-Null }

Write-Host "VaultGuard Active protecting: $VaultPath" -ForegroundColor Green

$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $VaultPath
$watcher.Filter = "*.md"
$watcher.IncludeSubdirectories = $true
$watcher.EnableRaisingEvents = $true

# Continuous background shadow-sync mirror to ensure shadow is ALWAYS populated
Start-Job -ScriptBlock {
    param($v, $s)
    while($true) {
        Get-ChildItem -Path $v -Filter "*.md" -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.FullName -notmatch '\\(\.git|\.trash|\.vault_shadow)\\' } | ForEach-Object {
            $rel = $_.FullName.Substring($v.Length).TrimStart('\')
            $dest = Join-Path $s $rel
            $destDir = Split-Path $dest -Parent
            if (!(Test-Path $destDir)) { New-Item -ItemType Directory -Force -Path $destDir | Out-Null }
            if (!(Test-Path $dest) -or ($_.LastWriteTime -gt (Get-Item $dest).LastWriteTime)) {
                Copy-Item -Path $_.FullName -Destination $dest -Force
            }
        }
        Start-Sleep -Seconds 5
    }
} -ArgumentList $VaultPath, $ShadowPath

$action = {
    param($sender, $e)
    $path = $e.FullPath
    if ($path -like "*\.git\*" -or $path -like "*\.trash\*" -or $path -like "*\.vault_shadow\*") { return }

    $relativePath = $path.Substring($VaultPath.Length).TrimStart('\')
    $shadowFile = Join-Path $ShadowPath $relativePath

    # If file was deleted, emptied, or violently truncated (< 50 bytes when it used to have content)
    $currentExists = Test-Path $path
    $currentLength = if ($currentExists) { (Get-Item $path).Length } else { 0 }

    if (-not $currentExists -or $currentLength -lt 50) {
        if (Test-Path $shadowFile) {
            $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            Add-Content -Path $LogPath -Value "[$timestamp] IMMORTAL RESTORE TRIGGERED: $path"
            
            $targetDir = Split-Path $path -Parent
            if (!(Test-Path $targetDir)) { New-Item -ItemType Directory -Force -Path $targetDir | Out-Null }
            
            Copy-Item -Path $shadowFile -Destination $path -Force
            
            Add-Type -AssemblyName System.Windows.Forms
            [System.Windows.Forms.MessageBox]::Show("VaultGuard resurrected deleted/wiped file:`n$relativePath", "Immortal Vault Shield", 0, 48)
        }
    }
}

Register-ObjectEvent $watcher "Changed" -Action $action
Register-ObjectEvent $watcher "Deleted" -Action $action
Register-ObjectEvent $watcher "Renamed" -Action $action

try {
    while ($true) { Start-Sleep -Seconds 2 }
} finally {
    Unregister-Event -SourceIdentifier *
}