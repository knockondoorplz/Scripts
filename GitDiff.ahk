; Ctrl + Win + Alt + D  →  git diff the two files selected in Explorer
^#!d::
{
    paths := []
    for window in ComObjCreate("Shell.Application").Windows() {
        if (window.HWND = WinExist("A")) {
            for item in window.Document.SelectedItems() {
                paths.Push(item.Path)
            }
        }
    }

    count := paths.MaxIndex()   ; <-- use this instead of paths.Length()

    if (count != 2) {
        MsgBox, 48, GitDiff, Please select exactly 2 files in Explorer.`nSelected: %count%
        return
    }

    f1 := paths[1]
    f2 := paths[2]
    script := "C:\Users\brigi\Documents\Jason\Scripts\GitDiff-Selected.ps1"

    Run, powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%script%" "%f1%" "%f2%",,
    return
}