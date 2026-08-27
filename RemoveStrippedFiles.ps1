# Run this inside the folder where the duplicates are
Get-ChildItem -File -Recurse | Where-Object { $_.Extension -match '\.(webm|mp3)$' } | ForEach-Object {
    $currentName = $_.Name
    $pattern = '^\d+[\s\-\.]*'
    
    # If the file starts with numbers/dashes
    if ($currentName -match $pattern) {
        # Figure out what the CLEAN name looks like
        $cleanName = $currentName -replace $pattern, ''
        $cleanFullPath = Join-Path $_.DirectoryName $cleanName
        
        # Check if the clean version already exists in that folder
        if (Test-Path $cleanFullPath) {
            Write-Host "Found duplicate! Deleting old numbered file: $currentName" -ForegroundColor Red
            Remove-Item $_.FullName -Force
        }
    }
}