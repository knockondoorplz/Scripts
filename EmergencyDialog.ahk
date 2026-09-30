#Requires AutoHotkey v2.0
#SingleInstance Force

; Win + Shift + O -> Native Open Dialog
>^>!o:: {
    selectedFile := ShowFileOpenDialog()
    if (selectedFile != "") {
        A_Clipboard := selectedFile
        ToolTip("Path copied & opened: " . selectedFile)
        SetTimer(() => ToolTip(), -2500)
        Run('"' selectedFile '"')
    }
}

; Win + Shift + S -> Native Save As / Target Dialog
>^>!s:: {
    selectedFile := ShowFileSaveDialog()
    if (selectedFile != "") {
        A_Clipboard := selectedFile
        ToolTip("Target path copied: " . selectedFile)
        SetTimer(() => ToolTip(), -2500)
    }
}

ShowFileOpenDialog() {
    o := ComObject("MsComDlg.CommonDialog")
    ; Fallback to native FileSelect if COM dlg fails on modern builds:
    selected := FileSelect(3, "C:\", "Emergency Open File", "All Files (*.*)")
    return selected
}

ShowFileSaveDialog() {
    selected := FileSelect("S", "C:\", "Emergency Save As", "All Files (*.*)")
    return selected
}