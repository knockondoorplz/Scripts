#Requires AutoHotkey v2.0
#SingleInstance Force
global SortMode := "Alpha", MyGui := ""

^+!h:: {
    global SortMode, MyGui
    SortMode := (SortMode == "Alpha" ? "Key" : "Alpha")
    ToolTip("Sort: " SortMode)
    SetTimer () => ToolTip(), -1000
    if (MyGui != "") {
        MyGui.Destroy()
        MyGui := ""
        Send("^+h") ; Refresh UI with new sort
    }
}

^+h:: {
    global MyGui, SortMode
    if (MyGui != "") {
        MyGui.Destroy()
        MyGui := ""
        return
    }
    
    MapFile := "C:\Users\brigi\Documents\Jason\Scripts\All_My_Hotkeys.txt"
    if !FileExist(MapFile)
        return
    
    RawText := FileRead(MapFile)
    ; Use v2 Sort with the callback functions defined below
    SortedText := (SortMode == "Alpha") ? Sort(RawText, "F SortByFilename") : Sort(RawText, "F SortByHotkey")
    
    MyGui := Gui("+AlwaysOnTop -Caption +ToolWindow +Border")
    MyGui.BackColor := "0A0A0A"
    MyGui.SetFont("s12", "Segoe UI")
    MyGui.OnEvent("Escape", (*) => (MyGui.Destroy(), MyGui := ""))
    MyGui.Add("Edit", "r20 w700 ReadOnly Background101010 c00FFFF", SortedText)
    MyGui.Show()
}

; Index 2 is the filename part (after the ::)
SortByFilename(a, b, *) {
    fileA := StrSplit(a, "::")[2]
    fileB := StrSplit(b, "::")[2]
    return StrCompare(fileA, fileB)
}

; Index 1 is the hotkey part (before the ::)
SortByHotkey(a, b, *) {
    keyA := StrSplit(a, "::")[1]
    keyB := StrSplit(b, "::")[1]
    return StrCompare(keyA, keyB)
}