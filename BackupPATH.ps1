# Backup PATHs to your desktop
$desktop = [Environment]::GetFolderPath('Desktop')

[Environment]::GetEnvironmentVariable("PATH","User")    |
    Set-Content "$desktop\UserPathBackup.txt"

[Environment]::GetEnvironmentVariable("PATH","Machine") |
    Set-Content "$desktop\SystemPathBackup.txt"
