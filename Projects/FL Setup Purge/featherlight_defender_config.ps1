Write-Host " Optimizing Windows Defender…" -ForegroundColor Cyan

Set-MpPreference -MAPSReporting Disabled
Set-MpPreference -SubmitSamplesConsent NeverSend
Set-MpPreference -PUAProtection 1
Set-MpPreference -DisableRealtimeMonitoring $false
Set-MpPreference -ScanAvgCPULoadFactor 15
Set-MpPreference -DisableArchiveScanning $true
Set-MpPreference -DisableEmailScanning $true
Set-MpPreference -DisableScriptScanning $false

Write-Host " Defender optimized. " -ForegroundColor Green
