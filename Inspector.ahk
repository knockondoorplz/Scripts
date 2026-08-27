#Requires AutoHotkey v2.0
#SingleInstance Force

global InspectorActive := false
global hGui := ""

#!i:: {
    global InspectorActive, hGui
    if (InspectorActive) {
        SetTimer(WatchCursor, 0)
        if (hGui) {
            hGui.Destroy()
            hGui := ""
        }
        InspectorActive := false
    } else {
        CreateInspector()
        InspectorActive := true
    }
}

CreateInspector() {
    global hGui
    hGui := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x20")
    hGui.BackColor := "222222"
    hGui.SetFont("s12", "Consolas")
    hGui.Add("Text", "vMyText w400 h60 c00FFFF", "Inspector Active...")
    hGui.Show("x1200 y100 NoActivate")
    SetTimer(WatchCursor, 100)
}

WatchCursor() {
    global hGui
    if !hGui
        return

    MouseGetPos(&mX, &mY, &id, &ctrl)
    
    try {
        title := WinGetTitle("ahk_id " id)
        class := WinGetClass("ahk_id " id)
        proc  := WinGetProcessName("ahk_id " id)
        
        hGui["MyText"].Value := "Title: " title "`nClass: " class "`nProcess: " proc
        ; Move the GUI to follow the mouse
        hGui.Move(mX + 20, mY + 20)
    }
}

^Esc::ExitApp