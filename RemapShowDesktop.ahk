; Hold Right Click and scroll Down to Minimize All
RButton & WheelDown::
{
    Send, #m
}
return

; Hold Right Click and scroll Up to Restore All
RButton & WheelUp::Send, +#mt::
Send, +#m
return

; Restore normal right-click when clicked alone
RButton::Click, Right
