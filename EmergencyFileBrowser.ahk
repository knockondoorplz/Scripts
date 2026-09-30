#Requires AutoHotkey v2.0
#SingleInstance Force

^+!f:: {
    ; Default to user profile / home base instead of hardcoded folder
    targetDir := "C:\Users\brigi\Downloads"
    if !DirExist(targetDir)
        targetDir := A_MyDocuments

    browserGui := Gui("+ToolWindow +AlwaysOnTop +Resize", "Emergency File Browser - " targetDir)
    browserGui.BackColor := "1E1E1E"
    browserGui.SetFont("cFFFFFF s10", "Segoe UI")
    
    lv := browserGui.Add("ListView", "w550 h380 Background252525 c00FFCC", ["File Name", "Size (KB)", "Modified"])
    
    PopulateList(lv, targetDir)

    lv.OnEvent("DoubleClick", (*) => OpenSelectedFile(lv, &targetDir))
    browserGui.Show()
}

PopulateList(lv, dir) {
    lv.Delete()
    loop files dir "\*.*" {
        fileTime := A_LoopFileTimeModified
        formattedTime := FormatTime(fileTime, "yyyy-MM-dd HH:mm")
        lv.Add("", A_LoopFileName, A_LoopFileSizeKB, formattedTime)
    }
    lv.ModifyCol(1, 320)
    lv.ModifyCol(2, 90)
    lv.ModifyCol(3, 120)
}

OpenSelectedFile(lv, &dir) {
    rowNumber := lv.GetNext(0, "Focused")
    if (rowNumber = 0)
        return
    fileName := lv.GetText(rowNumber, 1)
    fullPath := dir "\" fileName
    if DirExist(fullPath) {
        dir := fullPath
        PopulateList(lv, dir)
    } else {
        Run('"' fullPath '"')
    }
}