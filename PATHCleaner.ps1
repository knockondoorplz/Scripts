# ============================
# CONSERVATIVE PATH CLEANUP
# - No moving programs
# - No deleting files
# - Only dedupe + remove BAD entries
# - Add C:\Tools if missing
# - Full backup + log
# ============================

$desktop = [Environment]::GetFolderPath("Desktop")
$logFile = "$desktop\PATH_CLEANUP_LOG.txt"

"=== CONSERVATIVE PATH CLEANUP LOG ===" | Out-File $logFile
"Timestamp: $(Get-Date)" | Out-File $logFile -Append
"" | Out-File $logFile -Append

# ----------------------------
# 1. Backup USER + SYSTEM PATH
# ----------------------------
$userPath  = [Environment]::GetEnvironmentVariable("PATH", "User")
$sysPath   = [Environment]::GetEnvironmentVariable("PATH", "Machine")

$userBackup = "$desktop\USER_PATH_BACKUP.txt"
$sysBackup  = "$desktop\SYSTEM_PATH_BACKUP.txt"

$userPath | Out-File $userBackup
$sysPath  | Out-File $sysBackup

"Backed up USER PATH → $userBackup" | Out-File $logFile -Append
"Backed up SYSTEM PATH → $sysBackup" | Out-File $logFile -Append
"" | Out-File $logFile -Append

# ----------------------------
# 2. Clean PATH entries
# ----------------------------
function Clean-PathList {
    param($pathList)

    $entries = $pathList.Split(";") |
        ForEach-Object { $_.Trim() } |
        Where-Object { $_ -ne "" } |
        Select-Object -Unique

    # Remove BAD entries (folders that do not exist)
    $entries = $entries | Where-Object { Test-Path $_ }

    # Remove trailing slashes
    $entries = $entries | ForEach-Object { $_.TrimEnd("\") }

    return $entries
}

$cleanUser = Clean-PathList $userPath

# Add C:\Tools if missing
if (!(Test-Path "C:\Tools")) {
    New-Item -ItemType Directory -Path "C:\Tools" | Out-Null
    "Created C:\Tools" | Out-File $logFile -Append
}

if (!($cleanUser -contains "C:\Tools")) {
    $cleanUser += "C:\Tools"
    "Added C:\Tools to USER PATH" | Out-File $logFile -Append
}

# ----------------------------
# 3. Write cleaned USER PATH
# ----------------------------
$newUserPath = ($cleanUser -join ";")

Set-ItemProperty -Path "HKCU:\Environment" -Name PATH -Value $newUserPath

"Applied cleaned USER PATH" | Out-File $logFile -Append
"" | Out-File $logFile -Append

"=== CLEANUP COMPLETE ===" | Out-File $logFile -Append
"Log saved to: $logFile" | Out-File $logFile -Append
