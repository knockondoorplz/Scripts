$AHKFolder = "C:\Users\brigi\Documents\Jason\Scripts"
$OutputFile = Join-Path $AHKFolder "Brain_Hacked_Hotkeys.txt"
$Bindings = [System.Collections.Generic.List[PSCustomObject]]::new()

# Function to turn cryptic AHK prefixes into clean mental triggers
function Convert-Modifiers ($keyString) {
    $mod = ""
    if ($keyString -like '*^*') { $mod += "Ctrl+" }
    if ($keyString -like '*!*') { $mod += "Alt+" }
    if ($keyString -like '*#*') { $mod += "Win+" }
    if ($keyString -like '*+*') { $mod += "Shift+" }
    $cleanKey = $keyString -replace '[\^!#\+]',''
    return "$mod$cleanKey"
}

# 1. Gather AHK
Get-ChildItem -Path $AHKFolder -Filter *.ahk | ForEach-Object {
    $file = $_.Name
    Get-Content $_.FullName | ForEach-Object {
        $line = $_.Trim()
        if ($line -match '^(?<trigger>.*?)::(?<action>.*)') {
            $rawTrig = $Matches['trigger'].Trim()
            $action = $Matches['action'].Trim()
            if ($rawTrig -notlike ';*') {
                $friendlyTrig = Convert-Modifiers $rawTrig
                $Bindings.Add([PSCustomObject]@{ Hotkey = $friendlyTrig; Action = $action; Source = "AHK ($file)" })
            }
        }
    }
}

# 2. Gather VS Code
$VSCodePath = "$env:APPDATA\Code\User\keybindings.json"
if (Test-Path $VSCodePath) {
    $Json = Get-Content $VSCodePath -Raw | ConvertFrom-Json
    foreach ($b in $Json) {
        $Bindings.Add([PSCustomObject]@{ Hotkey = $b.key; Action = $b.command; Source = "VS Code" })
    }
}

# 3. Gather Cursor
$CursorPath = "$env:APPDATA\Cursor\User\keybindings.json"
if (Test-Path $CursorPath) {
    $Json = Get-Content $CursorPath -Raw | ConvertFrom-Json
    foreach ($b in $Json) {
        $Bindings.Add([PSCustomObject]@{ Hotkey = $b.key; Action = $b.command; Source = "Cursor" })
    }
}

# Format into a linear sequence sorted by the Hotkey itself
$Report = [System.Collections.Generic.List[string]]::new()
$Report.Add("=====================================================================")
$Report.Add("               THE HOMUNCULUS MAP (HOTKEY-FIRST SEQUENCE)            ")
$Report.Add("=====================================================================")
$Report.Add("")

$Bindings | Sort-Object Hotkey | ForEach-Object {
    $Report.Add( [string]::Format("{0,-30} -> {1,-40} [{2}]", $_.Hotkey, $_.Action, $_.Source) )
}

$Report | Out-File $OutputFile -Encoding utf8
Write-Host "The sequence is mapped! Open: $OutputFile" -ForegroundColor Cyan