param(
    [string]$File = "Ok.txt",
    [string]$VaultPath = "H:\Jason's Files\NewTempFolder"
)

# 1. Kill any lingering Java processes holding vault locks
Stop-Process -Name "java" -Force -ErrorAction SilentlyContinue

# 2. Masked Password Prompt
$SecurePass = Read-Host "Enter Vault Password" -AsSecureString
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePass)
$PlainPass = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

# 3. Launch Cryptomator via WinFsp
$cliJar = "$env:USERPROFILE\cryptomator-cli\cryptomator-cli.jar"

Write-Host "Mounting Vault to Drive X:..." -ForegroundColor Cyan
$pinfo = New-Object System.Diagnostics.ProcessStartInfo
$pinfo.FileName = "java"
$pinfo.Arguments = "-jar `"$cliJar`" --frontend winfsp --vault MyVault=`"$VaultPath`" --mountpoint MyVault=X: --passwordfile MyVault=-"
$pinfo.RedirectStandardInput = $true
$pinfo.UseShellExecute = $false
$pinfo.CreateNoWindow = $true

$process = [System.Diagnostics.Process]::Start($pinfo)
$process.StandardInput.WriteLine($PlainPass)
$process.StandardInput.Close()

# Wipe password from memory immediately
[System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR)
$PlainPass = $null

# 4. Wait up to 5 seconds and check if Drive X: actually mounted
$timeout = 5
while (-not (Test-Path "X:\") -and $timeout -gt 0) {
    Start-Sleep -Seconds 1
    $timeout--
}

# If Drive X: failed to mount (e.g. wrong password), ABORT!
if (-not (Test-Path "X:\")) {
    Write-Host "`n[ERROR] Failed to mount vault. Incorrect password or vault locked." -ForegroundColor Red
    Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue
    exit
}

# 5. Open target file in Notepad
$targetPath = "X:\$File"
Write-Host "Editing $File on encrypted drive X:... Close Notepad when finished." -ForegroundColor Yellow
notepad $targetPath

# 6. Clean up and unmount upon closing Notepad
Write-Host "Unmounting Drive X: and locking vault..." -ForegroundColor Red
Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue

Write-Host "Vault locked safely!" -ForegroundColor Green
