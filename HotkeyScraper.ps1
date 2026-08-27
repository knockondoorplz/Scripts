$AHKFolder = "C:\Users\brigi\Documents\Jason\Scripts"
$OutputFile = Join-Path $AHKFolder "Master_Hotkey_Map.txt"
$Report = [System.Collections.Generic.List[string]]::new()

# ---- 1. AUTOHOTKEY SCRIPTS ----
$Report.Add("=========================================")
$Report.Add("   AUTOHOTKEY CUSTOM SHORTCUTS")
$Report.Add("=========================================")
Get-ChildItem -Path $AHKFolder -Filter *.ahk | ForEach-Object {
    $FileName = $_.Name
    Get-Content $_.FullName | ForEach-Object {
        $Line = $_.Trim()
        if ($Line -match '(?<!^;.*)::') {
            $Report.Add("[$FileName] -> $Line")
        }
    }
}
$Report.Add("")

# ---- 2. VS CODE ----
$VSCodePath = "$env:APPDATA\Code\User\keybindings.json"
if (Test-Path $VSCodePath) {
    $Report.Add("=========================================")
    $Report.Add("   VISUAL STUDIO CODE HOTKEYS")
    $Report.Add("=========================================")
    $Json = Get-Content $VSCodePath -Raw | ConvertFrom-Json
    foreach ($binding in $Json) {
        $Report.Add("[$($binding.key)] -> $($binding.command)")
    }
    $Report.Add("")
}

# ---- 3. CURSOR EDITOR ----
$CursorPath = "$env:APPDATA\Cursor\User\keybindings.json"
if (Test-Path $CursorPath) {
    $Report.Add("=========================================")
    $Report.Add("   CURSOR EDITOR HOTKEYS")
    $Report.Add("=========================================")
    $Json = Get-Content $CursorPath -Raw | ConvertFrom-Json
    foreach ($binding in $Json) {
        $Report.Add("[$($binding.key)] -> $($binding.command)")
    }
    $Report.Add("")
}

# Output everything
$Report | Out-File $OutputFile -Encoding utf8
Write-Host "Boom! Unified hotkey map generated at: $OutputFile" -ForegroundColor Green