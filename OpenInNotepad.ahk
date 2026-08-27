#Requires AutoHotkey v2.0

#n::
{
    ; Get the active window.
    hwnd := WinGetID("A")

    ; Search every open Explorer window until we find the active one.
    for win in ComObject("Shell.Application").Windows
    {
        if (win.hwnd != hwnd)
            continue

        ; This is the active Explorer window.
        items := win.Document.SelectedItems()

        ; If nothing is selected, just open a blank Notepad.
        if (items.Count = 0)
        {
            Run "notepad.exe"
            return
        }

        ; Otherwise, open every selected file in Notepad.
        Loop items.Count
        {
            file := items.Item(A_Index - 1).Path
            Run 'notepad.exe "' file '"'
        }

        return
    }

    ; If the active window wasn't Explorer at all,
    ; treat Win+N like "New Notepad".
    Run "notepad.exe"
}