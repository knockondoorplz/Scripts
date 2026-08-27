#Requires AutoHotkey v2.0
#SingleInstance Force

!m::
{
    ToolTip("Press a number (1-9)...")
    ih := InputHook("L1 T4", "{Esc}")
    ih.Start()
    ih.Wait()
    ToolTip()
    
    if (ih.Input != "") {
        SendText("📍" . ih.Input)
    } else {
        MsgBox("Hook timed out or escaped without input.")
    }