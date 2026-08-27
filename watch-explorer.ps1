$tempFile = "$env:TEMP\last_explorer_path.txt"

while ($true) {
    try {
        $shell = New-Object -ComObject Shell.Application
        # Find the active window
        $active = $shell.Windows() | Where-Object { $_.HWND -eq (Get-Process | Where-Object {$_.MainWindowTitle} | Where-Object {$_.MainWindowHandle -eq (Get-ForegroundWindow).Handle}).MainWindowHandle } | Select-Object -First 1
        
        if ($active) {
            $path = [Uri]::UnescapeDataString($active.Document.Folder.Self.Path)
            if ($path -ne (Get-Content $tempFile -ErrorAction SilentlyContinue)) {
                $path | Out-File $tempFile
            }
        }
    } catch {}
    Start-Sleep -Seconds 1
}