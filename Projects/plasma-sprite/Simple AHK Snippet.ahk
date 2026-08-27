; Simple AHK snippet — get active window rect and send to Rainmeter via Run command (bang)
#Persistent
SetTimer, WatchActive, 120
last_hw := ""
rainmeterPath := "C:\Program Files\Rainmeter\Rainmeter.exe" ; adjust if needed

WatchActive:
 WinGet, hw, ID, A
 if (hw != last_hw) {
    last_hw := hw
    WinGetPos, X, Y, W, H, ahk_id %hw%
    ; compute a target point (for demo, we'll pick top-left corner)
    tx := X + 8
    ty := Y + 8
    ; send a Rainmeter bangs file (or use !CommandMeasure). Simpler: write coords to a small file read by Rainmeter's Lua.
    FileDelete, %A_Temp%\virescent_coords.json
    coords := "{""x"":" tx ", ""y"":" ty ", ""w"":" W ", ""h"":" H "}"
    FileAppend, %coords%, %A_Temp%\virescent_coords.json
    ; optionally trigger a refresh bang:
    Run, "%rainmeterPath%" !ActivateConfig "Virescent\Virescent.ini" , , Hide
 }
return
