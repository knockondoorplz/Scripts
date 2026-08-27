#Requires AutoHotkey v2.0
#SingleInstance Force

; =========================================================================
; 1. FILE PATH CONFIGURATION
; =========================================================================
global FilePath1 := "H:\Jason's Files\!NTY1T10XYZ\𐌰𐌹𐍂𐌿𐌽𐍄𐌹𐌲𐌹𐍃\♟Åcâdэмΐä💡\💿_Ċøðΐηg_💎\Scratchbox\🔱👁‍🗨\🔱👁‍🗨.md"
global FilePath2 := "H:\Jason's Files\!NTY1T10XYZ\𐌰𐌹𐍂𐌿𐌽𐍄𐌹𐌲𐌹𐍃\♟Åcâdэмΐä💡\💿_Ċøðΐηg_💎\Scratchbox\Some @%$! Code\Some @%$! Code.md"
global FilePath3 := "H:\Jason's Files\!NTY1T10XYZ\𐌰𐌹𐍂𐌿𐌽𐍄𐌹𐌲𐌹𐍃\øмegå_🌓\Ambitia\Tools🔧\💻сøмքսէэя⌨️\Desktop Apps\AI Entities\ChatGPT\For ChatGPT\🎭For ChatGPT.md"

global ActiveFilePath := FilePath1
global MainGui := ""
global TabCtrl := ""
global TV := ""
global TextEditor := ""
global SearchInput := ""
global ReplaceInput := ""
global FullDocText := ""
global IsGuiVisible := false
global IsLoading := false
global LastKnownModTime := 0
global LastKnownCaretPos := 0

; Build controls upfront so TextEditor and TV exist before any hotkey fires
BuildGUI()

; =========================================================================
; 2. SYSTEM-WIDE HOTKEYS
; =========================================================================

; Ctrl + Alt + J -> Mode 1: New Bullet (Or Universal Dismiss)
^!j::
{
    global IsGuiVisible
    if IsGuiVisible {
        DismissGUI()
    } else {
        OpenOrSwitchMode("NewBullet")
    }
}

; Ctrl + Shift + Alt + J -> Mode 2: View Only
^+!j:: OpenOrSwitchMode("ViewOnly")

; Ctrl + Shift + Alt + K -> Mode 3: Restore Last Caret Position
^+#j:: OpenOrSwitchMode("RestoreCursor")

; =========================================================================
; 3. GUI-FOCUSED HOTKEYS
; =========================================================================
#HotIf WinActive("ahk_id " . (IsObject(MainGui) ? MainGui.Hwnd : 0))

Esc:: DismissGUI()

^f::
{
    global SearchInput
    if IsObject(SearchInput) {
        SearchInput.Focus()
        Send("^a")
    }
}

^h::
{
    global ReplaceInput
    if IsObject(ReplaceInput) {
        ReplaceInput.Focus()
        Send("^a")
    }
}

^s:: SaveCurrentDocument(true)

#HotIf

; =========================================================================
; 4. CORE CONTROLLER FUNCTIONS
; =========================================================================

OpenOrSwitchMode(ModeName) {
    global IsGuiVisible
    if !IsGuiVisible {
        ShowGUI(ModeName)
    } else {
        LoadFileToEditor(ModeName)
    }
}

DismissGUI() {
    global MainGui, IsGuiVisible
    if IsGuiVisible {
        SaveCurrentCursorPosition()
        SaveCurrentDocument(false)
        MainGui.Hide()
        IsGuiVisible := false
    }
}

SaveCurrentCursorPosition() {
    global TextEditor, LastKnownCaretPos
    if IsObject(TextEditor) && TextEditor.Hwnd {
        buf := Buffer(8, 0)
        SendMessage(0x00B0, buf.Ptr, buf.Ptr + 4, TextEditor) ; EM_GETSEL
        LastKnownCaretPos := NumGet(buf, 0, "UInt")
    }
}

ReadUtf8File(Path) {
    if !FileExist(Path)
        return ""
    try {
        fileObj := FileOpen(Path, "r", "UTF-8")
        content := fileObj.Read()
        fileObj.Close()
        return content
    } catch {
        return ""
    }
}

; =========================================================================
; 5. GUI BUILDER & LOADER ENGINE
; =========================================================================

BuildGUI() {
    global MainGui, TabCtrl, TV, TextEditor, SearchInput, ReplaceInput
    
    MainGui := Gui("+AlwaysOnTop +ToolWindow +Resize", "🌊 Vector Aqua Vault")
    MainGui.BackColor := "0x0a1e3f"
    
    MainGui.SetFont("s9 Bold c0x00d2ff", "Segoe UI Emoji")
    MainGui.Add("Text", "x10 y10 w45 h20", "🔍 Find:")
    
    MainGui.SetFont("s9 Norm c0x000000", "Segoe UI")
    SearchInput := MainGui.Add("Edit", "x55 y6 w120 h22 c0x000000")
    SearchInput.OnEvent("Change", OnSearchChange)

    MainGui.SetFont("s9 Bold c0x00ffcc", "Segoe UI Emoji")
    MainGui.Add("Text", "x185 y10 w45 h20", "🔄 Swap:")
    
    MainGui.SetFont("s9 Norm c0x000000", "Segoe UI")
    ReplaceInput := MainGui.Add("Edit", "x230 y6 w120 h22 c0x000000")

    BtnReplace := MainGui.Add("Button", "x358 y5 w65 h24", "Swap All")
    BtnReplace.OnEvent("Click", OnReplaceClick)

    BtnSave := MainGui.Add("Button", "x430 y5 w100 h24", "💾 Save (Ctrl+S)")
    BtnSave.OnEvent("Click", (*) => SaveCurrentDocument(true))

    MainGui.SetFont("s9 Bold c0xe0f7fa", "Segoe UI")
    TabCtrl := MainGui.Add("Tab2", "x10 y34 w740 h500", ["🔱 Vault", "📋 Snippets", "🤖 AI Notes"])
    TabCtrl.UseTab()

    TV := MainGui.Add("TreeView", "x15 y65 w240 h460 Background0x061830 c0xe0f7fa -Lines")

    MainGui.SetFont("s10 Norm c0xffffff", "Consolas")
    TextEditor := MainGui.Add("Edit", "x260 y65 w485 h460 Background0x051428 c0xffffff Multi WantTab VScroll HScroll")
    
    TextEditor.OnEvent("Change", (*) => QueueAutoSave())
    TabCtrl.OnEvent("Change", OnTabChange)
    TV.OnEvent("ItemSelect", OnNodeSelect)

    SetTimer(CheckExternalFileEdits, 1000)
}

ShowGUI(Mode := "NewBullet") {
    global MainGui, IsGuiVisible
    MainGui.Show("Center w760 h545")
    IsGuiVisible := true
    try WinSetTransparent(235, MainGui.Hwnd)
    LoadFileToEditor(Mode)
}

OnTabChange(Ctrl, *) {
    global ActiveFilePath, FilePath1, FilePath2, FilePath3
    SaveCurrentDocument(false)
    switch Ctrl.Value {
        case 1: ActiveFilePath := FilePath1
        case 2: ActiveFilePath := FilePath2
        case 3: ActiveFilePath := FilePath3
    }
    LoadFileToEditor("ViewOnly")
}

LoadFileToEditor(OpenMode := "NewBullet") {
    global TV, TextEditor, ActiveFilePath, FullDocText, LastKnownModTime, LastKnownCaretPos, IsLoading
    
    if !IsObject(TV) || !IsObject(TextEditor)
        return

    IsLoading := true

    TV.Opt("-Redraw")
    TV.Delete()
    FullDocText := ""

    if !FileExist(ActiveFilePath) {
        IsLoading := false
        TV.Opt("+Redraw")
        TextEditor.Value := "⚠️ File not found at path:`n" . ActiveFilePath
        return
    }

    FullDocText := ReadUtf8File(ActiveFilePath)
    LastKnownModTime := FileGetTime(ActiveFilePath, "M")

    TargetBulletIndex := 2
    caretPos := 0

    if (OpenMode == "NewBullet") {
        if (FullDocText == "") {
            FullDocText := "- "
            caretPos := 2
        } else {
            targetCharIdx := 0
            foundCount := 0
            searchPos := 1

            while RegExMatch(FullDocText, "m`a)^[\t ]*-\s+", &match, searchPos) {
                foundCount++
                if (foundCount == TargetBulletIndex) {
                    targetCharIdx := match.Pos - 1
                    break
                }
                searchPos := match.Pos + match.Len
            }

            if (targetCharIdx == 0) {
                part1 := RTrim(FullDocText, "`r`n")
                FullDocText := part1 . "`r`n- "
                caretPos := StrLen(FullDocText)
            } else {
                part1 := SubStr(FullDocText, 1, targetCharIdx)
                part2 := SubStr(FullDocText, targetCharIdx + 1)
                part1 := RTrim(part1, "`r`n")
                part2 := LTrim(part2, "`r`n")
                FullDocText := part1 . "`r`n- `r`n" . part2
                caretPos := StrLen(part1) + 4
            }
        }
    } 
    else if (OpenMode == "RestoreCursor") {
        caretPos := Min(LastKnownCaretPos, StrLen(FullDocText))
    }

    TextEditor.Value := FullDocText
    IsLoading := false

    RootID := TV.Add("📜 FULL DOCUMENT", 0, "Expand Select")
    Parents := [0, 0, 0, 0, 0, 0]

    Loop Parse, FullDocText, "`n", "`r" {
        line := A_LoopField
        if RegExMatch(line, "^(#+)\s+(.*)", &match) {
            level := StrLen(match[1])
            title := match[2]

            parentId := RootID
            Loop level - 1 {
                idx := level - A_Index
                if (Parents[idx] != 0) {
                    parentId := Parents[idx]
                    break
                }
            }

            CurrentID := TV.Add(title, parentId, "Expand")
            Parents[level] := CurrentID
            
            Loop 6 - level
                Parents[level + A_Index] := 0
        }
    }

    TV.Opt("+Redraw")
    
    TextEditor.Focus()
    SendMessage(0x00B1, caretPos, caretPos, TextEditor) ; EM_SETSEL
    SendMessage(0x00B7, 0, 0, TextEditor)                 ; EM_SCROLLCARET
}

QueueAutoSave() {
    global IsLoading
    if IsLoading
        return
    static AutoSaveCallback := () => SaveCurrentDocument(false)
    SetTimer(AutoSaveCallback, 0)
    SetTimer(AutoSaveCallback, -400)
}

SaveCurrentDocument(showNotification := true) {
    global ActiveFilePath, TextEditor, LastKnownModTime, IsLoading
    if !IsObject(TextEditor) || IsLoading
        return

    SplitPath(ActiveFilePath, &fileName, &fileDir)
    if (fileDir != "" && !DirExist(fileDir)) {
        try DirCreate(fileDir)
    }

    try {
        fileObj := FileOpen(ActiveFilePath, "w", "UTF-8")
        fileObj.Write(TextEditor.Value)
        fileObj.Close()

        try FileSetTime(A_Now, ActiveFilePath)
        LastKnownModTime := FileGetTime(ActiveFilePath, "M")

        if showNotification {
            ToolTip("💾 Saved!")
            SetTimer(() => ToolTip(), -1000)
        }
    } catch {
        if showNotification {
            ToolTip("❌ Save Failed")
            SetTimer(() => ToolTip(), -1000)
        }
    }
}

CheckExternalFileEdits() {
    global ActiveFilePath, LastKnownModTime, IsGuiVisible, IsLoading
    if !IsGuiVisible || IsLoading || !FileExist(ActiveFilePath)
        return

    try {
        currentModTime := FileGetTime(ActiveFilePath, "M")
        if (LastKnownModTime != 0 && currentModTime != LastKnownModTime) {
            LastKnownModTime := currentModTime
            LoadFileToEditor("ViewOnly")
        }
    }
}

OnNodeSelect(Control, ItemID) {
    global TextEditor
    if !IsObject(TextEditor)
        return

    itemText := TV.GetText(ItemID)
    if (itemText == "📜 FULL DOCUMENT" || itemText == "")
        return

    pos := InStr(TextEditor.Value, itemText)
    if pos {
        TextEditor.Focus()
        SendMessage(0x00B1, pos - 1, pos - 1, TextEditor)
        SendMessage(0x00B7, 0, 0, TextEditor)
    }
}

OnSearchChange(GuiCtrl, *) {
    global TextEditor
    if !IsObject(TextEditor)
        return

    query := GuiCtrl.Value
    if (query == "")
        return

    pos := InStr(TextEditor.Value, query)
    if pos {
        TextEditor.Focus()
        SendMessage(0x00B1, pos - 1, pos + StrLen(query) - 1, TextEditor)
        SendMessage(0x00B7, 0, 0, TextEditor)
    }
}

OnReplaceClick(*) {
    global SearchInput, ReplaceInput, TextEditor
    if !IsObject(TextEditor)
        return

    findStr := SearchInput.Value
    replaceStr := ReplaceInput.Value

    if (findStr == "")
        return

    if InStr(TextEditor.Value, findStr) {
        TextEditor.Value := StrReplace(TextEditor.Value, findStr, replaceStr)
        SaveCurrentDocument(true)
    }
}