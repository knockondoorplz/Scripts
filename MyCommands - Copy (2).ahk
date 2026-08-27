global SortMode := "Alpha"
global MyGui := unset

^+h:: {
    global MyGui, SortMode
    if (MyGui != "") {
        MyGui.Destroy()
        MyGui := ""
        return
    }
    
    MapFile := "C:\Users\brigi\Documents\Jason\Scripts\All_My_Hotkeys.txt"
    RawText := FileRead(MapFile)
    
    ; Sort the list (which is already clean!)
    if (SortMode == "Alpha")
        SortedText := Sort(RawText, "F SortByFilename")
    else
        SortedText := Sort(RawText, "F SortByHotkey")
    
    ; Display
    MyGui := Gui("+AlwaysOnTop -Caption +ToolWindow +Border")
    MyGui.BackColor := "0A0A0A"
    MyGui.SetFont("s14", "Positions By Arixbored")
    MyGui.OnEvent("Escape", (*) => (MyGui.Destroy(), MyGui := ""))
    MyGui.Add("Button", "w0 h0 vDummy", "")
    MyGui.Add("Edit", "r30 w800 ReadOnly Background101010 c00FFFF", SortedText)
    MyGui.Show("w820")
    MyGui["Dummy"].Focus()
}

; The Sort functions are now super simple because the data is clean
SortByFilename(a, b, *) {
    return StrCompare(Trim(StrSplit(a, "::")[2]), Trim(StrSplit(b, "::")[2]))
}

SortByHotkey(a, b, *) {
    return StrCompare(Trim(StrSplit(a, "::")[1]), Trim(StrSplit(b, "::")[1]))
}