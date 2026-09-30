#Requires AutoHotkey v2.0
#SingleInstance Force

; =========================================================================
; 1. PATH CONFIGURATION & GLOBAL STATE
; =========================================================================
global RawPath1 := "H:\Jason's Files\!NTY1T10XYZ\𐌰𐌹𐍂𐌿𐌽𐍄𐌹𐌲𐌹𐍃\♟Åcâdэмΐä💡\💿_Ċøðΐηg_💎\Scratchbox\🔱👁‍🗨\🔱👁‍🗨.md"
global RawPath2 := "H:\Jason's Files\!NTY1T10XYZ\𐌰𐌹𐍂𐌿𐌽𐍄𐌹𐌲𐌹𐍃\♟Åcâdэмΐä💡\💿_Ċøðΐηg_💎\Scratchbox\Some @%$! Code\Some @%$! Code.md"
global RawPath3 := "H:\Jason's Files\!NTY1T10XYZ\𐌰𐌹𐍂𐌿𐌽𐍄𐌹𐌲𐌹𐍃\øмegå_🌓\Ambitia\Projects\For Agents.md"

global FilePath1 := ResolvePath(RawPath1)
global FilePath2 := ResolvePath(RawPath2)
global FilePath3 := ResolvePath(RawPath3)

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

; Dynamic Fold Memory Bank (HeaderTitle -> FullContentBlock)
global FoldedSections := Map()

; =========================================================================
; 2. CORE HELPER FUNCTIONS
; =========================================================================

ResolvePath(PathStr) {
    if FileExist(PathStr)
        return PathStr

    cleanPath := RegExReplace(PathStr, "[\x{200B}-\x{200D}\x{FE0F}]", "")
    if FileExist(cleanPath)
        return cleanPath

    SplitPath(cleanPath, &fileName, &fileDir)
    if DirExist(fileDir) {
        Loop Files, fileDir . "\*.md" {
            return A_LoopFilePath
        }
    }
    return PathStr
}

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

FocusSafeActivate(WinTarget) {
    if !WinExist(WinTarget)
        return

    hwnd := WinGetID(WinTarget)
    minMax := WinGetMinMax(hwnd)

    if (minMax == -1)
        WinRestore(hwnd)

    WinSetAlwaysOnTop(true, hwnd)
    WinActivate(hwnd)
    Sleep(10)
    WinSetAlwaysOnTop(false, hwnd)
}

; =========================================================================
; 3. ACCURATE TELEPORTATION & SEARCH ENGINE
; =========================================================================

JumpToTextInEditor(targetStr, setFocusToEditor := false) {
    global TextEditor
    if !IsObject(TextEditor) || targetStr == ""
        return false

    fullText := TextEditor.Value
    if (fullText == "")
        return false

    ; Clean invisible UTF characters from target comparison
    cleanTarget := RegExReplace(targetStr, "[\x{200B}-\x{200D}\x{FE0F}]", "")
    
    pos := 0
    matchLen := StrLen(targetStr)

    ; 1. Direct search
    pos := InStr(fullText, targetStr)
    
    ; 2. Cleaned fallback search
    if !pos {
        cleanDoc := RegExReplace(fullText, "[\x{200B}-\x{200D}\x{FE0F}]", "")
        pos := InStr(cleanDoc, cleanTarget)
    }

    ; 3. Header line RegEx matching fallback
    if !pos {
        escapedTarget := RegExReplace(cleanTarget, "([\\.*?+^{}()\[\]|$^])", "\$1")
        if RegExMatch(fullText, "i)m)^#+\s+.*?" . escapedTarget, &m) {
            pos := m.Pos(0)
            matchLen := m.Len(0)
        }
    }

    if !pos
        return false

    ; Convert Character Index to Win32 EM_SETSEL Byte Offset
    subText := SubStr(fullText, 1, pos - 1)
    
    ; Account for CRLF (\r\n) line breaks in Edit Control
    crlfCount := 0
    StrReplace(subText, "`r`n", "`r`n", &crlfCount)
    
    startPos := (pos - 1) - crlfCount
    endPos := startPos + matchLen

    if setFocusToEditor
        TextEditor.Focus()

    ; EM_SETSEL (0x00B1) & EM_SCROLLCARET (0x00B7)
    SendMessage(0x00B1, startPos, endPos, TextEditor)
    SendMessage(0x00B7, 0, 0, TextEditor)
    return true
}

; =========================================================================
; 4. IN-EDITOR NON-DESTRUCTIVE FOLDING ENGINE
; =========================================================================

ToggleHeaderFoldAtCursor() {
    global TextEditor, FoldedSections
    if !IsObject(TextEditor)
        return

    fullText := TextEditor.Value
    
    ; Get caret position
    buf := Buffer(8, 0)
    SendMessage(0x00B0, buf.Ptr, buf.Ptr + 4, TextEditor)
    caretPos := NumGet(buf, 0, "UInt") + 1

    lines := StrSplit(fullText, "`n", "`r")
    charAccum := 0
    targetLineIdx := 0

    For idx, line in lines {
        charAccum += StrLen(line) + 2
        if (charAccum >= caretPos) {
            targetLineIdx := idx
            break
        }
    }

    if (targetLineIdx == 0)
        return

    ; Find current or preceding header
    headerLineIdx := 0
    Loop targetLineIdx {
        idx := targetLineIdx - A_Index + 1
        if RegExMatch(lines[idx], "^(#+)\s+(.*)", &m) {
            headerLineIdx := idx
            headerLevel := StrLen(m[1])
            headerTitle := m[2]
            break
        }
    }

    if (headerLineIdx == 0) {
        ToolTip("⚠️ No Header found above cursor!")
        SetTimer(() => ToolTip(), -1200)
        return
    }

    ; Check if header is currently folded
    if FoldedSections.Has(headerTitle) {
        ; --- UNFOLD PROCESS ---
        restoredContent := FoldedSections[headerTitle]
        FoldedSections.Delete(headerTitle)

        ; Re-insert content below header
        newLines := []
        For idx, line in lines {
            newLines.Push(line)
            if (idx == headerLineIdx) {
                newLines.Push(restoredContent)
            }
        }
        
        rebuiltText := ""
        For line in newLines {
            rebuiltText .= (A_Index == 1 ? "" : "`r`n") . line
        }
        
        TextEditor.Value := rebuiltText
        ToolTip("📂 Unfolded: " . headerTitle)
        SetTimer(() => ToolTip(), -1000)
    } else {
        ; --- FOLD PROCESS ---
        foldBlockLines := []
        endLineIdx := lines.Length

        Loop lines.Length - headerLineIdx {
            idx := headerLineIdx + A_Index
            line := lines[idx]
            
            if RegExMatch(line, "^(#+)\s+", &m) {
                if (StrLen(m[1]) <= headerLevel) {
                    endLineIdx := idx - 1
                    break
                }
            }
        }

        if (endLineIdx <= headerLineIdx) {
            ToolTip("⚠️ Nothing to fold under this header!")
            SetTimer(() => ToolTip(), -1200)
            return
        }

        ; Extract body lines to memory
        blockStr := ""
        Loop endLineIdx - headerLineIdx {
            idx := headerLineIdx + A_Index
            blockStr .= (A_Index == 1 ? "" : "`r`n") . lines[idx]
        }

        FoldedSections[headerTitle] := blockStr

        ; Rebuild document with folded block removed
        newLines := []
        For idx, line in lines {
            if (idx <= headerLineIdx || idx > endLineIdx) {
                newLines.Push(line)
            }
        }

        rebuiltText := ""
        For line in newLines {
            rebuiltText .= (A_Index == 1 ? "" : "`r`n") . line
        }

        TextEditor.Value := rebuiltText
        ToolTip("📁 Folded: " . headerTitle)
        SetTimer(() => ToolTip(), -1000)
    }
}

; Navigating between headers in Editor
JumpToHeaderInEditor(Direction := "Next") {
    global TextEditor
    if !IsObject(TextEditor)
        return

    buf := Buffer(8, 0)
    SendMessage(0x00B0, buf.Ptr, buf.Ptr + 4, TextEditor)
    caretPos := NumGet(buf, 0, "UInt") + 1

    fullText := TextEditor.Value
    lines := StrSplit(fullText, "`n", "`r")
    
    charAccum := 0
    currentLineIdx := 1
    For idx, line in lines {
        charAccum += StrLen(line) + 2
        if (charAccum >= caretPos) {
            currentLineIdx := idx
            break
        }
    }

    targetLine := 0
    if (Direction == "Next") {
        Loop lines.Length - currentLineIdx {
            idx := currentLineIdx + A_Index
            if RegExMatch(lines[idx], "^#+\s+") {
                targetLine := idx
                break
            }
        }
    } else {
        Loop currentLineIdx - 1 {
            idx := currentLineIdx - A_Index
            if RegExMatch(lines[idx], "^#+\s+") {
                targetLine := idx
                break
            }
        }
    }

    if (targetLine > 0) {
        JumpToTextInEditor(lines[targetLine], true)
    }
}

TV_SetAllExpand(Expand := true) {
    global TV
    if !IsObject(TV)
        return
    TV.Opt("-Redraw")
    ItemID := TV.GetNext(0, "Full")
    while ItemID {
        if (ItemID != 1) {
            if Expand
                TV.Modify(ItemID, "+Expand")
            else
                TV.Modify(ItemID, "-Expand")
        }
        ItemID := TV.GetNext(ItemID, "Full")
    }
    TV.Opt("+Redraw")
}

TV_ToggleActiveNode(Expand := true) {
    global TV
    if !IsObject(TV)
        return
    selectedID := TV.GetSelection()
    if (selectedID && selectedID != 1) {
        if Expand
            TV.Modify(selectedID, "+Expand")
        else
            TV.Modify(selectedID, "-Expand")
    }
}

BuildGUI()

; =========================================================================
; 5. HOTKEYS
; =========================================================================

<^<!j::
{
    if IsGuiVisible
        DismissGUI()
    else
        OpenOrSwitchMode("NewBullet")
}

<^<+<!j:: OpenOrSwitchMode("ViewOnly")
<^<+<#j:: OpenOrSwitchMode("RestoreCursor")
^#Insert:: Reload()

#1:: FocusSafeActivate("ahk_exe obsidian.exe")
#2:: FocusSafeActivate("ahk_exe explorer.exe")
#3:: FocusSafeActivate("ahk_exe notepad.exe")

; =========================================================================
; 6. GUI BUILDER & EVENT HANDLERS
; =========================================================================

#HotIf (IsObject(MainGui) && MainGui.Hwnd && WinActive("ahk_id " . MainGui.Hwnd))

Esc:: DismissGUI()

; Navigation & In-Editor Folding
^Up:: JumpToHeaderInEditor("Prev")
^Down:: JumpToHeaderInEditor("Next")
^l:: ToggleHeaderFoldAtCursor()            ; Ctrl+L: Fold/Unfold Current Section

; TreeView Folding
^+!Up:: TV_SetAllExpand(false)
^+!Down:: TV_SetAllExpand(true)
^+Up:: TV_ToggleActiveNode(false)
^+Down:: TV_ToggleActiveNode(true)

!n::
{
    global TextEditor
    if IsObject(TextEditor)
        ControlSend("- ", TextEditor)
}

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

BuildGUI() {
    global MainGui, TabCtrl, TV, TextEditor, SearchInput, ReplaceInput
    
    MainGui := Gui("+AlwaysOnTop +ToolWindow +Resize", "🌊 Vector Aqua Vault")
    MainGui.BackColor := "0x0a1e3f"
    
    MainGui.SetFont("s9 Bold c0x00d2ff", "Segoe UI Emoji")
    MainGui.Add("Text", "x10 y10 w45 h20", "🔍 Find:")
    
    MainGui.SetFont("s9 Norm c0x000000", "Segoe UI")
    SearchInput := MainGui.Add("Edit", "x55 y6 w100 h22 c0x000000")
    SearchInput.OnEvent("Change", OnSearchChange)

    MainGui.SetFont("s9 Bold c0x00ffcc", "Segoe UI Emoji")
    MainGui.Add("Text", "x160 y10 w45 h20", "🔄 Swap:")
    
    MainGui.SetFont("s9 Norm c0x000000", "Segoe UI")
    ReplaceInput := MainGui.Add("Edit", "x205 y6 w100 h22 c0x000000")

    BtnReplace := MainGui.Add("Button", "x310 y5 w60 h24", "Swap")
    BtnReplace.OnEvent("Click", OnReplaceClick)

    BtnColAll := MainGui.Add("Button", "x375 y5 w30 h24", "📁-")
    BtnColAll.OnEvent("Click", (*) => TV_SetAllExpand(false))

    BtnExpAll := MainGui.Add("Button", "x408 y5 w30 h24", "📂+")
    BtnExpAll.OnEvent("Click", (*) => TV_SetAllExpand(true))

    BtnColAct := MainGui.Add("Button", "x441 y5 w30 h24", "➖")
    BtnColAct.OnEvent("Click", (*) => TV_ToggleActiveNode(false))

    BtnExpAct := MainGui.Add("Button", "x474 y5 w30 h24", "➕")
    BtnExpAct.OnEvent("Click", (*) => TV_ToggleActiveNode(true))

    BtnSave := MainGui.Add("Button", "x510 y5 w100 h24", "💾 Save (Ctrl+S)")
    BtnSave.OnEvent("Click", (*) => SaveCurrentDocument(true))

    MainGui.SetFont("s9 Bold c0xe0f7fa", "Segoe UI")
    TabCtrl := MainGui.Add("Tab2", "x10 y34 w740 h500", ["🔱👁‍🗨", "📋 Some @%$! Code", "🎭 For Agents"])
    TabCtrl.UseTab()

    TV := MainGui.Add("TreeView", "x15 y65 w240 h460 Background0x061830 c0xe0f7fa -Lines")

    MainGui.SetFont("s10 Norm c0xffffff", "Consolas")
    TextEditor := MainGui.Add("Edit", "x260 y65 w485 h460 Background0x051428 c0xffffff Multi WantTab VScroll HScroll")
    
    TextEditor.OnEvent("Change", (*) => QueueAutoSave())
    TabCtrl.OnEvent("Change", OnTabChange)
    TV.OnEvent("ItemSelect", OnNodeSelect)
    TV.OnEvent("DoubleClick", OnNodeDoubleClick)

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
    global ActiveFilePath, FilePath1, FilePath2, FilePath3, FoldedSections
    SaveCurrentDocument(false)
    FoldedSections.Clear() ; Reset in-memory folds when switching documents
    
    switch Ctrl.Value {
        case 1: ActiveFilePath := FilePath1
        case 2: ActiveFilePath := FilePath2
        case 3: ActiveFilePath := FilePath3
    }
    LoadFileToEditor("ViewOnly")
}

LoadFileToEditor(OpenMode := "NewBullet") {
    global TV, TextEditor, TabCtrl, ActiveFilePath, FullDocText, LastKnownModTime, LastKnownCaretPos, IsLoading
    
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

    currentTab := IsObject(TabCtrl) ? TabCtrl.Value : 1
    caretPos := 0

    if (currentTab == 1 && OpenMode == "NewBullet") {
        FullDocText := "- `r`n" . FullDocText
        caretPos := 2
    } 
    else if (OpenMode == "RestoreCursor") {
        caretPos := Min(LastKnownCaretPos, StrLen(FullDocText))
    }

    TextEditor.Value := FullDocText

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
    SendMessage(0x00B1, caretPos, caretPos, TextEditor)
    SendMessage(0x00B7, 0, 0, TextEditor)

    IsLoading := false
}

; Single-click header teleportation
OnNodeSelect(Control, ItemID) {
    global TV
    if !IsObject(TV) || ItemID == 0
        return

    itemText := TV.GetText(ItemID)
    if (itemText == "📜 FULL DOCUMENT" || itemText == "")
        return

    JumpToTextInEditor(itemText, false) ; Scroll & select in editor without dropping TreeView focus
}

; Double-click header teleportation
OnNodeDoubleClick(Control, ItemID) {
    global TV
    if !IsObject(TV) || ItemID == 0
        return

    itemText := TV.GetText(ItemID)
    if (itemText == "📜 FULL DOCUMENT" || itemText == "")
        return

    JumpToTextInEditor(itemText, true) ; Jump directly into Text Editor
}

; Real-time Find box callback
OnSearchChange(GuiCtrl, *) {
    query := GuiCtrl.Value
    if (query == "")
        return

    JumpToTextInEditor(query, false)
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

QueueAutoSave() {
    global IsLoading
    if IsLoading
        return
    static AutoSaveCallback := () => SaveCurrentDocument(false)
    SetTimer(AutoSaveCallback, 0)
    SetTimer(AutoSaveCallback, -400)
}

SaveCurrentDocument(showNotification := true) {
    global ActiveFilePath, TextEditor, LastKnownModTime, IsLoading, FoldedSections
    if !IsObject(TextEditor) || IsLoading
        return

    SplitPath(ActiveFilePath, &fileName, &fileDir)
    if (fileDir != "" && !DirExist(fileDir)) {
        try DirCreate(fileDir)
    }

    try {
        ; Unfold any currently folded sections before saving to disk so no text is lost
        saveText := TextEditor.Value
        For headerTitle, blockStr in FoldedSections {
            if RegExMatch(saveText, "i)m)^#+\s+" . RegExReplace(headerTitle, "([\\.*?+^{}()\[\]|$^])", "\$1"), &m) {
                pos := m.Pos(0) + m.Len(0)
                sub1 := SubStr(saveText, 1, pos)
                sub2 := SubStr(saveText, pos + 1)
                saveText := sub1 . "`r`n" . blockStr . sub2
            }
        }

        fileObj := FileOpen(ActiveFilePath, "w", "UTF-8")
        fileObj.Write(saveText)
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

SaveCurrentCursorPosition() {
    global TextEditor, LastKnownCaretPos
    if IsObject(TextEditor) && TextEditor.Hwnd {
        buf := Buffer(8, 0)
        SendMessage(0x00B0, buf.Ptr, buf.Ptr + 4, TextEditor)
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