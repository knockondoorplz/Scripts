# Forces Windows to aggressively flush idle memory pages back to the system
$wmi = Get-CimInstance Win32_Process
foreach ($proc in $wmi) {
    try {
        [Runtime.InteropServices.Marshal]::MinimizeFootprint([IntPtr]$proc.ProcessId)
    } catch {}
}
Write-Host "Memory working sets trimmed. Check Task Manager now!" -ForegroundColor Green