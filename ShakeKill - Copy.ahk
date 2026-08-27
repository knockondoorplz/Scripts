#Requires AutoHotkey v2.0
Persistent

SetTimer(WatchShake, 50)

WatchShake() {
    static lastX := 0, lastY := 0, shakeIntensity := 0, shakeStartTime := 0
    
    MouseGetPos(&x, &y)
    dist := Abs(x - lastX) + Abs(y - lastY)
    
    ; Only count movement if it's "jittery" (rapid back-and-forth)
    ; Long smooth drags (dist > 100) are ignored
    if (dist > 20 && dist < 100) {
        shakeIntensity += dist
        if (shakeIntensity > 1000 && shakeStartTime == 0)
            shakeStartTime := A_TickCount
    } else {
        shakeIntensity := Max(0, shakeIntensity - 30)
        if (shakeIntensity < 500)
            shakeStartTime := 0
    }
    
    lastX := x, lastY := y
    
    ; Logic: Must be intense AND held for 3500ms
        if (shakeStartTime > 0 && (A_TickCount - shakeStartTime > 3500)) {
            shakeIntensity := 0, shakeStartTime := 0
            WinClose("A")
    }
 
    ToolTip("Intensity: " Round(shakeIntensity) (shakeStartTime ? " (HOLDING...)" : ""))
}