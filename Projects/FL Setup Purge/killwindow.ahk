DetectHiddenWindows, On

; Kill common ghost window classes
classes := ["IME", "SynTPEnh", "ETDCtrl", "ApMsgFwd", "Shell_TrayWnd", "Windows.UI.Core.CoreWindow"]

for index, cls in classes {
    WinGet, list, List, ahk_class %cls%
    Loop, %list%
        WinClose, ahk_id % list%A_Index%
}

; Kill any window titled "Default IME"
WinGet, list2, List, Default IME
Loop, %list2%
    WinClose, ahk_id % list2%A_Index%

; Kill any window titled "ForcePad Driver Tray Window"
WinGet, list3, List, ForcePad Driver Tray Window
Loop, %list3%
    WinClose, ahk_id % list3%A_Index%