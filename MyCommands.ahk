#Requires AutoHotkey v2.0
#SingleInstance Force
#Include JSON.ahk

;==========================================================
;
; MyCommands.ahk
;
; Displays ScriptIndex.json
;
; Responsibilities:
;
; - Show registered scripts
; - Show assigned hotkeys
; - Sort the index
; - Open scripts
;
; Does NOT:
;
; - Register scripts
; - Parse hotkeys
; - Modify the database
;
;==========================================================


global MyGui := ""
global SortColumn := 1

IndexFile := A_ScriptDir "\ScriptIndex.json"


^+j::
{
    global MyGui

    if (MyGui)
    {
        MyGui.Destroy()
        MyGui := ""
        return
    }

    ShowCommands()
}

ShowCommands()
{
    global MyGui

    MyGui := Gui(
        "+AlwaysOnTop -Caption +ToolWindow",
        "MyCommands"
    )

    MyGui.BackColor := "101018"

    MyGui.SetFont(
        "s12",
        "Positions By Arixbored"
    )

    LV := MyGui.Add(
        "ListView",
        "w900 h500 Grid",
        [
            "id",
            "Hotkey",
            "Function",
            "Filename",
            "Created",
            "Modified",
            "Path",
        ]
    )

    LV.Name := "CommandList"

    LV.OnEvent(
        "DoubleClick",
        OpenSelected
    )


    LoadIndex(LV)


    MyGui.SetFont(
        "s10",
        "Positions By Arixbored"
    )

    MyGui.AddText(
        "xm y+10",
        "ScriptIndex"
    )


    MyGui.Show()
}



LoadIndex(LV)
{
    IndexFile := A_ScriptDir "\ScriptIndex.json"

    if !FileExist(IndexFile)
        return

    Data := JSON.parse(FileRead(IndexFile), false, false)

    if !IsObject(Data)
        return

    for script in Data
    {
        if script.HasOwnProp("bindings")
        {
            for binding in script.bindings
            {
                functionName := ""

                if binding.HasOwnProp("function") && binding.function
                    functionName := binding.function

                LV.Add(
                    "",
                    script.id,
                    binding.hotkey,
                    functionName,
                    script.filename,
                    script.created,
                    script.modified,
                    script.path
                )
            }
        }
        else if script.HasOwnProp("hotkeys")
        {
            ; Backward compatibility with older index entries

            for key in script.hotkeys
            {
                LV.Add(
                    "",
                    script.id,
                    key,
                    "",
                    script.filename,
                    script.created,
                    script.modified,
                    script.path
                )
            }
        }
    }

    LV.ModifyCol(1, "AutoHdr")
    LV.ModifyCol(2, "AutoHdr")
    LV.ModifyCol(3, "AutoHdr")
    LV.ModifyCol(4, "AutoHdr")
    LV.ModifyCol(5, "AutoHdr")
    LV.ModifyCol(6, "AutoHdr")
    LV.ModifyCol(7, "AutoHdr")
}

RefreshList()
{
    global MyGui

    for control in MyGui
    {
        if (control.Type = "ListView")
        {
            control.Delete()
            LoadIndex(control)
            break
        }
    }
}



OpenSelected(LV, Row)
{
    path := LV.GetText(Row,7)

    if FileExist(path)
        Run(
            "notepad.exe " '"' path '"'
        )
}