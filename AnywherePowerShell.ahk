#Requires AutoHotkey v2.0
#SingleInstance Force

CapsLock & Space:: {
    ShowPowerShell()
}


ShowPowerShell() {
    psGui := Gui("+AlwaysOnTop +Resize", "⚡ Anywhere PowerShell")
    psGui.BackColor := "101218"
    psGui.MarginX := 16
    psGui.MarginY := 16

    psGui.SetFont("s11 cFFFFFF", "Segoe UI")
    psGui.AddText("w560", "⚡ Anywhere PowerShell")

    psGui.SetFont("s10 cAAAAAA", "Consolas")
    psGui.AddText("xm y+12", "PowerShell command")

    psGui.SetFont("s10 cFFFFFF", "Consolas")
    input := psGui.AddEdit("xm y+6 w560 h70")

    psGui.SetFont("s10 cAAAAAA", "Consolas")
    psGui.AddText("xm y+14", "Output")

    psGui.SetFont("s10 cFFFFFF", "Consolas")
    output := psGui.AddEdit("xm y+6 w560 h220 ReadOnly Multi")

    runButton := psGui.AddButton("xm y+12 w100", "RUN")
    closeButton := psGui.AddButton("x+8 w100", "CLOSE")

    runButton.OnEvent("Click", (*) => RunPowerShell(input, output))
    closeButton.OnEvent("Click", (*) => psGui.Destroy())

    psGui.OnEvent("Close", (*) => psGui.Destroy())
    psGui.OnEvent("Escape", (*) => psGui.Destroy())

    psGui.Show("w600 h430")

    input.Focus()
}

RunPowerShell(input, output) {
    command := input.Value

    if (Trim(command) = "") {
        output.Value := "Enter a PowerShell command first."
        return
    }

    tempFile := A_Temp "\AnywherePS_" A_TickCount ".txt"

    try {
        RunWait(
            'powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "'
            . StrReplace(command, '"', '\"')
            . ' 2>&1 | Out-File -Encoding utf8 "'
            . tempFile
            . '"',
            ,
            "Hide"
        )

        if FileExist(tempFile) {
            result := FileRead(tempFile, "UTF-8")
            FileDelete(tempFile)
            output.Value := result
        } else {
            output.Value := "PowerShell returned no output."
        }

    } catch as err {
        output.Value := "ERROR:`n`n" err.Message
    }
}