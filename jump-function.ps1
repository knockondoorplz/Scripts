# 🏁 The Explorer Window Jumper
function jump {
    $shell = New-Object -ComObject Shell.Application
    # Get the top-most/active Windows Explorer window
    $activeExplorer = $shell.Windows() | Where-Object { $_.Name -eq "File Explorer" } | Select-Object -Last 1
    
    if ($activeExplorer) {
        $path = [Uri]::UnescapeDataString($activeExplorer.Document.Folder.Self.Path)
        Set-Location $path
        Write-Host "🛸 Jumped to: $path" -ForegroundColor Cyan
    } else {
        Write-Host "⚠️ No active File Explorer window detected." -ForegroundColor Yellow
    }
}