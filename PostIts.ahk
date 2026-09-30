#Requires AutoHotkey v2.0
#SingleInstance Force

global g_hue := 0

MButton:: {
    A_Clipboard := ""
    Send("^c")
    if !ClipWait(0.15)
        return
    
    liftedText := A_Clipboard
    if (liftedText = "")
        return

    CoordMode("Mouse", "Screen")
    MouseGetPos(&mX, &mY)
    
    lineArray := StrSplit(liftedText, "`n", "`r")
    lineCount := lineArray.Length
    
    maxLen := 0
    for each, line in lineArray {
        if (StrLen(line) > maxLen)
            maxLen := StrLen(line)
    }
    
    boxWidth := Max(Min(maxLen * 8 + 25, 400), 120)
    boxHeight := Max(lineCount * 18 + 20, 40)

    ; Borderless, tooltip-style floating window
    note := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x08000000")
    note.BackColor := "0A192F"
    
    note.SetFont("s14", "Neotriad")
    txtCtrl := note.Add("Text", "x12 y10 w" (boxWidth - 24) " h" (boxHeight - 20) " BackgroundTrans c64FFDA", liftedText)
    
    ; Drag window from anywhere on the note
    txtCtrl.OnEvent("Click", (*) => PostItDrag(note))
    note.OnEvent("ContextMenu", (*) => note.Destroy())
    HotKey("Escape", (*) => note.Destroy(), "On")
    
    note.Show("w" boxWidth " h" boxHeight " x" (mX + 15) " y" (mY + 15))
    
    ; Spin up a fast timer to cycle the font through a smooth rainbow spectrum while it's open
    SetTimer(() => CycleRainbowFont(txtCtrl, note), 50)
}

CycleRainbowFont(ctrl, guiObj) {
    global g_hue
    if !WinExist(guiObj.Hwnd) {
        SetTimer(, 0)
        return
    }
    g_hue := Mod(g_hue + 3, 360)
    rgbColor := HSL2RGB_Hex(g_hue, 1.0, 0.7)
    ctrl.Opt("c" rgbColor)
}

PostItDrag(guiObj) {
    PostMessage(0xA1, 2, 0, guiObj.Hwnd)
}

HSL2RGB_Hex(h, s, l) {
    c := (1 - Abs(2 * l - 1)) * s
    x := c * (1 - Abs(Mod(h / 60, 2) - 1))
    m := l - c/2
    if (h >= 0 && h < 60)
        r := c, g := x, b := 0
    else if (h >= 60 && h < 120)
        r := x, g := c, b := 0
    else if (h >= 120 && h < 180)
        r := 0, g := c, b := x
    else if (h >= 180 && h < 240)
        r := 0, g := x, b := c
    else if (h >= 240 && h < 300)
        r := x, g := 0, b := c
    else
        r := c, g := 0, b := x
    
    ri := Integer((r + m) * 255)
    gi := Integer((g + m) * 255)
    bi := Integer((b + m) * 255)
    return Format("{:02X}{:02X}{:02X}", ri, gi, bi)
}