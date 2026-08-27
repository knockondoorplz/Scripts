#Requires AutoHotkey v2.0
; 1. Declare at the top so it's always available
Global TempFile := A_Temp "\refactor_input.txt"

; 2. Your Hotkey
^+r:: {
    Send("^c")
    if !ClipWait(1)
        return
        
    FileDelete(TempFile)
    FileAppend(A_Clipboard, TempFile)

    Loop {
        RunWait('powershell.exe -File "C:\Users\brigi\Documents\Jason\Scripts\Refactor.ps1" -Path "' TempFile '"',, "Hide")
        
        NewCode := FileRead(TempFile)
        Result := ShowRefactorGui(NewCode) 
        
        ; Corrected IF blocks
        if (Result == "Accept") {
            A_Clipboard := NewCode
            Send("^v")
            break
        }
        
        if (Result == "Cancel") {
            break 
        }

    } ; This brace closes the Loop
} ; This brace closes the Hotkey

; 4. The GUI Function (Must be after the Hotkey, not before)
ShowRefactorGui(CodeToDisplay) {
    local Result := "Retry" 
    MyGui := Gui("+AlwaysOnTop +Border", "Refactor Preview")
    MyGui.SetFont("s10", "Consolas")
    
    MyGui.Add("Edit", "r15 w600 ReadOnly", CodeToDisplay)
    btnAccept := MyGui.Add("Button", "w100", "Accept")
    btnRetry  := MyGui.Add("Button", "w100", "Refactor Again")
    
    ; Update these lines in ShowRefactorGui
    btnAccept.OnEvent("Click", (*) => (Result := "Accept", MyGui.Destroy()))
    btnRetry.OnEvent("Click",  (*) => (Result := "Retry",  MyGui.Destroy()))
    MyGui.OnEvent("Escape",    (*) => (Result := "Cancel", MyGui.Destroy())) ; ESC = Cancel
    
    MyGui.Show()
    WinWaitClose(MyGui)
    return Result
}