#Requires AutoHotkey v2

; Win+N → open all selected files in Notepad
#n::
{
    hwnd := WinGetID("A")

    for win in ComObject("Shell.Application").Windows
        if win.hwnd = hwnd {
            items := win.Document.SelectedItems()
            if items.Count = 0
                return

            ; Loop through COM collection
            Loop items.Count {
                file := items.Item(A_Index - 1).Path
                Run 'notepad.exe "' . file . '"'
            }
            return
        }
}
