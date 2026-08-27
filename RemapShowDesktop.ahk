; 1. TAP LEFT ALT TWICE TO SHOW DESKTOP (MINIMIZE ALL)
~LAlt::
if (A_PriorHotkey = "~LAlt" and A_TimeSincePriorHotkey < 400)
{
    Send, #m
}
return

; 2. PRESS BOTH ALTS TO RESUME DESKTOP (RESTORE ALL)
LAlt & RAlt::
Send, +#m
return

RAlt & LAlt::
Send, +#m
return