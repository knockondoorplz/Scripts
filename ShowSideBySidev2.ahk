#Requires AutoHotkey v2.0
#SingleInstance Force

F9::{
    ShowSideBySide()
}

ShowSideBySide()
{
    windows := WinGetList("A")

    movable := []

    for hwnd in windows
    {
        try
        {
            title := WinGetTitle(hwnd)

            if title != ""
                movable.Push(hwnd)
        }
    }

    count := movable.Length

    if count = 0
        return

    MonitorGetWorkArea(1, &left, &top, &right, &bottom)

    width := (right-left)/count

    for index, hwnd in movable
    {
        x := left + ((index-1)*width)

        WinRestore(hwnd)
        WinMove(
            x,
            top,
            width,
            bottom-top,
            hwnd
        )
    }
}