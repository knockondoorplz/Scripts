#Requires AutoHotkey v1

SetTimer, ReconcileWindows, 200

ReconcileWindows:
    WinGet, id, List
    Loop %id%
    {
        this_id := id%A_Index%

        ; enforce visibility rule
        EnsureAnchorVisible(this_id)

        ; enforce cascade offset
        ApplyCascadingOffset(this_id)
    }
return