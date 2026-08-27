#Requires AutoHotkey v2.0
^+`:: {
    if WinActive("ahk_class CabinetWClass") {
        hwnd := WinActive("A")
        shell := ComObject("Shell.Application")
        for window in shell.Windows {
            if (window.HWND == hwnd) {
                path := window.Document.Folder.Self.Path
                ; Pass path as a single quoted string
                cmd := 'C:\Python312\python.exe "C:\Users\brigi\Documents\Jason\Scripts\Projects\Stack\stacktext.py" "' path '"'
                Run(cmd)
                break
            }
        }
    }
}