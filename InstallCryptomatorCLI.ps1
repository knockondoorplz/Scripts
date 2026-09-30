# 1. Install Java runtime if not present (Required for Cryptomator CLI JAR)
if (-not (Get-Command java -ErrorAction SilentlyContinue)) {
    Write-Host "Java not detected. Installing OpenJDK via winget..." -ForegroundColor Yellow
    winget install EclipseAdoptium.Temurin.17.JDK --accept-package-agreements --accept-source-agreements
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}

# 2. Setup directory
$cliPath = "$env:USERPROFILE\cryptomator-cli"
New-Item -ItemType Directory -Path $cliPath -Force | Out-Null

# 3. Download official Cryptomator CLI JAR file
$jarUrl = "https://github.com/cryptomator/cli/releases/download/0.4.0/cryptomator-cli-0.4.0.jar"
$jarFile = "$cliPath\cryptomator-cli.jar"

Write-Host "Downloading Cryptomator CLI JAR..." -ForegroundColor Cyan
Invoke-WebRequest -Uri $jarUrl -OutFile$jarFile

# 4. Create a batch script wrapper so 'cryptomator-cli' command works anywhere
$batContent = "@echo off`r`njava -jar `"$jarFile`" %*"
Set-Content -Path "$cliPath\cryptomator-cli.bat" -Value $batContent

# 5. Add to User PATH
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($userPath -notlike "*$cliPath*") {
    [Environment]::SetEnvironmentVariable("Path", "$userPath;$cliPath", "User")
    $env:Path += ";$cliPath"
    Write-Host "Cryptomator CLI added to PATH successfully." -ForegroundColor Green
} else {
    Write-Host "Cryptomator CLI path is already configured." -ForegroundColor Green
}
