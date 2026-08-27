#Requires AutoHotkey v2.0
#SingleInstance Force
SendMode("Input")

; === CONFIGURATION ===
obsidianPath := "C:\Users\Jason\iCloudDrive\iCloud~md~obsidian\!NTY1T10XYZ\"  ; destination folder
exportCount := 20   ; how many notes to export in this run (adjust as needed)
noteDelay   := 800  ; ms to wait for Notes to switch and copy

MsgBox("Make sure the iCloud Notes window is active and the first note is selected.`n`nPress OK to begin.")
Sleep(1000)

Loop exportCount
{
    ; Copy note text
    Send("^a")             ; Select All
    Sleep(100)
    Send("^c")             ; Copy
    Sleep(noteDelay)

    clip := A_Clipboard
    if (clip = "")
    {
        MsgBox("Clipboard was empty—stopping.")
        break
    }

    ; Get a simple filename using first line of text
    firstLine := StrSplit(clip, "`n")[1]
    fileName := RegExReplace(firstLine, "[^\w\s-]", "") ; remove illegal chars
    if (fileName = "")
        fileName := "Note_" A_Index
    filePath := obsidianPath fileName ".md"

    ; Write file
    FileAppend(clip, filePath, "UTF-8")

    ; Feedback
    ToolTip("Saved: " fileName)
    Sleep(800)
    ToolTip()

    ; Go to next note
    Send("{Down}")
    Sleep(noteDelay)
}
MsgBox("Finished exporting " A_Index " notes to " obsidianPath)
ExitApp
