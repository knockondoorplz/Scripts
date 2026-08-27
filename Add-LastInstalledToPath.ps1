function Add-LastInstalledToPath {
    # 1. Grab newest directory
    $progFiles = Get-ChildItem "C:\Program Files", "C:\Program Files (x86)" -Directory | 
                 Sort-Object CreationTime -Descending | 
                 Select-Object -First 1

    $targetFolder = $progFiles.FullName
    
    # 2. Get current SYSTEM path safely
    $currentPath = [Environment]::GetEnvironmentVariable("PATH", "System")
    if ($currentPath -like "*$targetFolder*") {
        Write-Host "ℹ️ $targetFolder is already in your System PATH!" -ForegroundColor Yellow
        return
    }

    # 3. Save directly to System scope
    $newPath = $currentPath + ";" + $targetFolder
    [Environment]::SetEnvironmentVariable("PATH", $newPath, "System")
    
    Write-Host "✅ Successfully added to System PATH: $targetFolder" -ForegroundColor Green
}