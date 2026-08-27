; Visual Linker Pro
; Select the parameter in ZGameEditor, then hit F1.
F1::
{
    ; Send MIDI learn/Link command
    Send, ^j ; Standard shortcut for 'Link to controller'
    WinWaitActive, Remote control settings
    
    ; Click the 'Internal controller' menu
    ControlClick, TComboBox1, A
    
    ; Move down to your designated Peak Controller
    ; Adjust the number of {Down} presses based on your list order
    Send, {Down 4} 
    Send, {Enter}
    
    ; Adjust mapping formula if needed (optional)
    ; Send, {Tab}{Tab} ; Navigates to the mapping formula box
    
    Send, {Enter} ; Accept
    return
}