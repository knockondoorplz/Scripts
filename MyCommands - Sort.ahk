#Requires AutoHotkey v2.0
#SingleInstance Force

global SortMode := "Alpha"
global MyGui := ""

^+!h:: {
    global SortMode, MyGui
    SortMode := (SortMode == "Alpha" ? "Key" : "Alpha")
    ToolTip("Sort: " SortMode)
    SetTimer () => ToolTip(), -1000
    
    if IsSet(MyGui) && MyGui != "" {
        MyGui.Destroy()
        MyGui := ""
        Send("^+h")
    }
}

^+h:: {
    global MyGui, SortMode
    if IsSet(MyGui) && MyGui != "" {
        MyGui.Destroy()
        MyGui := ""
        return
    }
    
    MapFile := "C:\Users\brigi\Documents\Jason\Scripts\All_My_Hotkeys.txt"
    if !FileExist(MapFile)
        return
    
    RawText := FileRead(MapFile)
    Lines := StrSplit(RawText, "`n", "`r")
    
    AlphaList := ""
    KeyList := ""
    
    ; Parse every line and build the two formats
    for line in Lines {
        if (line == "")
            continue
        
        ; Extract the Hotkey side and File side using Regex
        ; Matches: <Anything> [File: <Anything>]
        if RegExMatch(line, "(.*?) \[File: (.*?)\]", &Match) {
            HK := Trim(Match[1])
            FL := Trim(Match[2])
            
            ; Format 1: [Filename.ahk] -> Hotkey::
            AlphaList .= "[" FL "] -> " HK "`n"
            
            ; Format 2: Hotkey:: [File: Filename.ahk]
            KeyList .= HK " [File: " FL "]`n"
        } else {
            ; Fallback if a line is weird
            AlphaList .= line "`n"
            KeyList .= line "`n"
        }
    }
    
    ; Native Sort! Since we formatted the strings, AHK naturally sorts by the first character.
    AlphaList := Sort(Trim(AlphaList, "`n"))
    KeyList := Sort(Trim(KeyList, "`n"))
    
    ; Apply the requested Header for Alpha mode
    if (SortMode == "Alpha") {
        Header := "=========================================`n   AUTOHOTKEY CUSTOM SHORTCUTS`n=========================================`n"
        SortedText := Header . AlphaList
    } else {
        SortedText := KeyList
    }
    
    MyGui := Gui("+AlwaysOnTop -Caption +ToolWindow +Border")
    MyGui.BackColor := "0A0A0A"
    MyGui.SetFont("s12", "Consolas") ; Consolas keeps your brackets perfectly vertically aligned
    MyGui.OnEvent("Escape", (*) => (MyGui.Destroy(), MyGui := ""))
    
    ; THE DUMMY: A 0-pixel Button. Text controls sometimes refuse focus, buttons never do.
    MyGui.Add("Button", "w0 h0 vDummy", "") 
    
    MyGui.Add("Edit", "r30 w800 ReadOnly Background101010 c00FFFF", SortedText)
    MyGui.Show("w820")
    
    ; Force focus to the dummy button so the text stays unselected
    MyGui["Dummy"].Focus() 
}