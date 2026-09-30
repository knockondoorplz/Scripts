#Requires AutoHotkey v2.0
#SingleInstance Force

; >^>!o -> Emergency Open in Notepad & Copy Path
>^>!o:: {
    selectedFile := FileSelect(3, "C:\Users\brigi\Documents\Jason\Scripts", "Emergency Open File", "All Files (*.*)")
    if (selectedFile != "") {
        A_Clipboard := selectedFile  ; Fixed typo (removed trailing l)
        ToolTip("Path Copied & Opening in Notepad: " . selectedFile)
        SetTimer(() => ToolTip(), -2500)
        Run('notepad.exe "' selectedFile '"')  ; Fixed quote concatenation
    }
}

; >^>!m -> Emergency Quick File Mover (Bypasses Explorer completely)
>^>!m:: {
    srcFile := FileSelect(3, "C:\Users\brigi\Documents\Jason\Scripts\", "Select File to Move", "All Files (*.*)")
    if (srcFile = "")
        return
        
    ; Fixed parameter structure: Options, StartingFolder, Prompt
    destDir := FileSelectFolder(, "C:\Users\brigi\Documents\Jason\Scripts\", "Select Destination Folder")
    if (destDir = "")
        return
        
    SplitPath(srcFile, &fileName)
    destPath := destDir "\" fileName
    
    try {
        FileMove(srcFile, destPath, 1) ; 1 = overwrite if exists
        A_Clipboard := destPath
        ToolTip("Successfully Moved to:`n" . destPath)
        SetTimer(() => ToolTip(), -3500)
    } catch as err {
        MsgBox("Move failed: " . err.Message, "Emergency Mover Error", 16)
    }
}