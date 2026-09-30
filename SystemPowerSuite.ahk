; === SYSTEM POWER SUITE ===

; Ctrl + ` -> Sleep
^`::
DllCall("PowrProf\SetSuspendState", "int", 0, "int", 1, "int", 0)
return

; Alt + ` -> Sign Out
!`::
Shutdown, 0
return

; Win + ` -> Restart
#`::
Shutdown, 2
return

; Win + Alt + ` -> Shut Down (Requires intentional 2-modifier press)
#!`::
Shutdown, 1
return