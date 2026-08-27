#Requires AutoHotkey v2

; Ctrl+Win+R
; Roll the desktop into a simple tiled layout.

^#r::
{
    windows := []

    ; Collect every visible window.
    WinList := WinGetList()

    for hwnd in WinList
    {
        title := WinGetTitle(hwnd)

        ; Ignore tiny/system windows.
        if (title = "")
            continue

        if !WinExist("ahk_id " hwnd)
            continue

        windows.Push(hwnd)
    }

    count := windows.Length

    if (count = 0)
        return

    MonitorGetWorkArea(1, &L, &T, &R, &B)

    cols := Ceil(Sqrt(count))
    rows := Ceil(count / cols)

    cellW := Floor((R-L)/cols)
    cellH := Floor((B-T)/rows)

    i := 0

    for hwnd in windows
    {
        row := Floor(i / cols)
        col := Mod(i, cols)

        x := L + col * cellW
        y := T + row * cellH

        WinRestore(hwnd)

        ; animation later...
        WinMove(x, y, cellW, cellH, hwnd)

        i++
    }
}