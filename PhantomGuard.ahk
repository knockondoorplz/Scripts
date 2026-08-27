#Requires AutoHotkey v2.0

; Phantom Guard App Launcher
SmartLaunch(AppPath, AppName) {
    ; Rule 1: If computer has been idle > 10 seconds, block phantom background opens
    if (A_TimeIdlePhysical > 10000) {
        ToolTip("BLOCKED Phantom Background Open: " . AppName)
        SetTimer(() => ToolTip(), -3000)
        return false
    }

    ; Rule 2: High-risk apps require Shift key held down to prevent misclicks
    if (AppName in ["Calibre", "GuitarPro", "Obsidian", "FL Studio", "iTunes" ]) {
        if !GetKeyState("Shift", "P") {
            ToolTip("Shield Active: Hold SHIFT while opening " . AppName)
            SetTimer(() => ToolTip(), -2500)
            return false
        }
    }

    Run(AppPath)
}

; Shortcut Overrides (Wrap your app execution here)
>^>!c:: SmartLaunch("C:\Program Files\Calibre2\calibre.exe", "Calibre")
>^>!v:: SmartLaunch("code", "VSCode")