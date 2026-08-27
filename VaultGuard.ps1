# VaultGuard.ps1
$VaultPath = "H:\Jason's Files\!NTY1T10XYZ"
$LogPath = "$VaultPath\.trash\VaultGuard_Restores.log"

$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $VaultPath
$watcher.Filter = "*.md"
$watcher.IncludeSubdirectories = $true
$watcher.EnableRaisingEvents = $true

$fileSizes = @{}

$action = {
    $path = $Event.SourceEventArgs.FullPath
    if ($path -like "*\.git\*" -or $path -like "*\.trash\*") { return }

    $file = Get-Item $path -ErrorAction SilentlyContinue
    if (-not $file) { return }

    $oldSize = $fileSizes[$path]
    $fileSizes[$path] = $file.Length

    if ($oldSize -and $oldSize -gt 10000) { # Only guard files > 10KB
        $ratio = $file.Length / $oldSize
        if ($ratio -lt 0.20) { # Dropped by more than 80%
            $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            Add-Content -Path $LogPath -Value "[$timestamp] SUSPICIOUS DELETION: $path ($oldSize bytes -> $($file.Length) bytes)"
            
            # Use git checkout to immediately revert the file to its last committed state
            Set-Location $VaultPath
            git checkout -- "$path"
            
            # Notify user via Windows balloon tip
            [reflection.assembly]::loadwithpartialname("System.Windows.Forms")
            [System.Windows.Forms.MessageBox]::Show("VaultGuard stopped an automatic truncation on:`n$path", "File Loss Prevented", 0, 48)
        }
    }
}

Register-ObjectEvent $watcher "Changed" -Action $action
while ($true) { Start-Sleep -Seconds 2 }