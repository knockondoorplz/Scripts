#IfWinActive ahk_exe FL64.exe

; Use this to quickly open the Link menu and set a "Power" curve for your visuals
F1::
{
    Send, ^j ; Link to controller
    WinWaitActive, Remote control settings
    
    ; Select the first Peak Controller (Peak_Low)
    ControlClick, TComboBox1, A
    Send, {Down 1}{Enter} 
    
    ; Navigate to Mapping Formula
    Send, {Tab 4}
    
    ; Type a complex curve for "Tornado Precision" motion
    Send, Input^2{Enter} 
    
    ; Done
    return
}
#IfWinActive