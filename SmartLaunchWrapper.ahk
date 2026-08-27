#Requires AutoHotkey v2.0

; Smart App Launcher Example
SmartRun(TargetPath, RiskLevel := "Low") {
    ; Rule 1: Phantom check - If physical mouse/keyboard unused for >10s, block background opens
    if (A_TimeIdlePhysical > 10000) {
        ToolTip("BLOCKED Phantom Launch: " . TargetPath)
        SetTimer(() => ToolTip(), -3000)
        return false
    }

    ; Rule 2: High-risk apps (e.g. Calibre, Guitar Pro) require an explicit modifier key hold if clicked accidentally
    if (RiskLevel == "High") {
        if !KeyHistory() ; Check if physically initiated
        {
            ; Requires Shift key to be held down during launch to prevent misclicks
            if !GetKeyState("Shift", "P") {
                ToolTip("Launch Shielded: Hold SHIFT while opening " . TargetPath)
                SetTimer(() => ToolTip(), -2500)
                return false
            }
        }
    }

    Run(TargetPath)
}

; Usage Examples in your hotkey file:
+!l: SmartRun("C:\Program Files\Calibre2\calibre.exe", "High")
^!v:: SmartRun("code", "Low")