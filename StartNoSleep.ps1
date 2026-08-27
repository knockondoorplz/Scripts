# Equivalent to macOS caffeinate -dis: Keeps system/display/system awake
Add-Type @'
using System;
using System.Runtime.InteropServices;
public class Awake {
    [DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError = true)]
    public static extern EXECUTION_STATE SetThreadExecutionState(EXECUTION_STATE esFlags);
    public enum EXECUTION_STATE : uint {
        ES_AWAYMODE_REQUIRED = 0x00000040,
        ES_CONTINUOUS = 0x80000000,
        ES_DISPLAY_REQUIRED = 0x00000002,
        ES_SYSTEM_REQUIRED = 0x00000001
    }
}
'@ -ErrorAction SilentlyContinue

[Awake]::SetThreadExecutionState([Awake+EXECUTION_STATE]::ES_CONTINUOUS -bor [Awake+EXECUTION_STATE]::ES_SYSTEM_REQUIRED)

# Turn off screen immediately (no light)
$rundll = 'rundll32.exe'
& $rundll user32.dll,LockWorkStation  # Or: powrprof.dll,SetSuspendState 0,1,0 for sleep (screen off + low power)

Write-Host "Laptop awake, screen off. Run StopNoSleep.ps1 to restore."
Read-Host "Press Enter to exit (screen will restore on normal timeout)"