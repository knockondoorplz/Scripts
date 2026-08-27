^!i::
    ; Get path of active File Explorer window
    WinGetClass, explorerClass, A
    if (explorerClass != "CabinetWClass" && explorerClass != "ExploreWClass")
        return
    
    for window in ComObject("Shell.Application").Windows {
        if (window.hwnd == WinExist("A")) {
            currentPath := window.Document.Folder.Self.Path
            break
        }
    }

    if (!currentPath)
        return

    iniFile := currentPath . "\desktop.ini"

    ; Check if desktop.ini exists in this folder
    if (!FileExist(iniFile)) {
        MsgBox, 48, Icon Refresh, No desktop.ini found in:`n%currentPath%
        return
    }

    ; Set System/Read-Only attribute on the folder so Windows reads desktop.ini
    RunWait, cmd.exe /c attrib +r +s "%currentPath%", , Hide
    ; Ensure desktop.ini is Hidden + System
    RunWait, cmd.exe /c attrib +h +s "%iniFile%", , Hide

    ; Force Shell to notify Explorer of the change
    DllCall("shell32\SHChangeNotify", "UInt", 0x08000000, "UInt", 0, "Ptr", 0, "Ptr", 0)

    TrayTip, Icon Restored, Refreshing icon for:`n%currentPath%, 2
return