$scriptsPath = "C:\Users\brigi\Documents\Jason\Scripts\New folder"
$outputPath = Join-Path $scriptsPath "All_My_Hotkeys.txt"

$report = [System.Collections.Generic.List[string]]::new()
$report.Add("=== MASTER AUTOHOTKEY MAP ===")
$report.Add("")

Get-ChildItem -Path $scriptsPath -Filter *.ahk | ForEach-Object {
    $fileName = $_.Name
    $content = Get-Content $_.FullName
    
    foreach ($line in $content) {
        $trimmed = $line.Trim()
        # Match lines with '::' that don't start with a semicolon
        if ($trimmed -match '(?<!^;.*)::') {
            # Extract comment if it exists on the same line
            if ($trimmed -match '::(.*);(.*)') {
                $hotkey = $trimmed.Split(';')[0].Trim()
                $comment = $trimmed.Split(';')[1].Trim()
                $report.Add("$hotkey = $comment [File: $fileName]")
            } else {
                $report.Add("$trimmed [File: $fileName]")
            }
        }
    }
}

$report | Out-File $outputPath -Encoding utf8
Write-Host "Done! Saved to $outputPath"