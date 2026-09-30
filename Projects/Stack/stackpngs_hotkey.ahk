#Requires AutoHotkey v2.0

; Whole folder -> stacked.png (filters by approved image extensions)
^!`:: {
    if WinActive("ahk_class CabinetWClass") {
        hwnd := WinActive("A")
        shell := ComObject("Shell.Application")
        for window in shell.Windows {
            if (window.HWND == hwnd) {
                path := window.Document.Folder.Self.Path
                cmd := '"C:\Python312\python.exe" "C:\Users\brigi\Documents\Jason\Scripts\Projects\Stack\stackpngs.py" "' path '"'
                Run(cmd)
                break
            }
        }
    }
}

; Multi-select -> stacked.png (any selected images, one batched call, selection order preserved)
^+#`:: {
    python := "C:\Python312\python.exe"
    script := "C:\Users\brigi\Documents\Jason\Scripts\Projects\Stack\stackpngs.py"

    shell := ComObject("Shell.Application")
    cmd := '"' python '" "' script '"'
    count := 0

    for window in shell.Windows {
        if (window.HWND = WinExist("A")) {
            for item in window.Document.SelectedItems {
                cmd .= ' "' item.Path '"'
                count += 1
            }
            break
        }
    }

    if (count = 0) {
        ToolTip("Stackpngs: nothing selected")
        SetTimer(() => ToolTip(), -1500)
        return
    }

    Run(cmd)
    ToolTip("Stackpngs: stacking " count " image(s)")
    SetTimer(() => ToolTip(), -1500)
}
