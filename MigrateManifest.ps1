$Manifest = "C:\Users\brigi\Documents\Jason\Scripts\Manifest.txt"

$Indexer = "C:\Users\brigi\Documents\Jason\Scripts\IndexScript.ps1"


foreach ($line in Get-Content $Manifest)
{
    $Path = $line.Trim()

    if ($Path -and (Test-Path $Path))
    {
        powershell.exe `
        -NoProfile `
        -ExecutionPolicy Bypass `
        -File $Indexer `
        $Path
    }
}

Write-Host "Migration complete."