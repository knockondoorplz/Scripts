#Requires AutoHotkey v2.0

Global LastX := 0
Global LastY := 0
Global ShakeScore := 0

SetTimer(Func("WatchShake"), 50)

WatchShake() {
    global LastX, LastY, ShakeScore

    MouseGetPos(&x, &y)

    if (LastX = 0 && LastY = 0) {
        LastX := x, LastY := y
        return
    }

    dx := Abs(x - LastX)
    dy := Abs(y - LastY)
    dist := dx + dy

    if (dist > 80)
        ShakeScore += dist
    else
        ShakeScore := Max(0, ShakeScore - 50)

    LastX := x
    LastY := y

    if (ShakeScore > 1000) {
        ShakeScore := 0
        WinKill("A")  ; kill active window
    }
}
