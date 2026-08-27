; Press Ctrl+Alt+K to start cleaning upward.
^!k::
    Loop
    {
        ; Select current line
        Send, {Home}+{End}
        Sleep, 20
        
        ; Copy it silently
        Clipboard := ""
        Send, ^c
        ClipWait, 0.2
        
        line := Clipboard
        
        ; If current line is NOT empty, check the one above
        if (Trim(line) != "")
        {
            ; Move up to check next line
            Send, {Up}
            Sleep, 20
            
            ; Select that line
            Send, {Home}+{End}
            Sleep, 20
            
            Clipboard := ""
            Send, ^c
            ClipWait, 0.2
            
            if (Trim(Clipboard) != "")
            {
                ; Two non-empty lines in a row → stop
                return
            }
            
            ; Otherwise, delete line above
            Send, {Del}
            Sleep, 30
            
            ; Move up one after deletion so the loop continues correctly
            Send, {Up}
            Sleep, 20
        }
        else
        {
            ; The current line is empty → delete it
            Send, {Del}
            Sleep, 30
            
            ; After deleting, move up
            Send, {Up}
            Sleep, 20
        }
    }
return
