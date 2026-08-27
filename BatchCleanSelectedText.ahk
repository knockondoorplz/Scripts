; Batch clean selected text 
; Press Ctrl+Alt+L to clean:

^!l::
    ; Copy selection
    Clipboard := ""
    Send, ^c
    ClipWait, 0.3
    if (!Clipboard)
        return

    text := Clipboard

    ; Remove multiple consecutive blank lines → single blank line
    ; This collapses ANY run of \n\n\n\n… into exactly \n\n
    cleaned := RegExReplace(text, "(\R\s*\R)+", "`r`n")

    ; Put cleaned text back on the clipboard and paste
    Clipboard := cleaned
    Send, ^v
return
