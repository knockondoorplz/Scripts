$progressPreference = 'silentlyContinue'
# Get the latest winget msixbundle download URL
$latestWingetMsixBundleUri = $(Invoke-RestMethod https://api.github.com/repos/microsoft/winget-cli/releases/latest).assets.browser_download_url | Where-Object { $_.EndsWith(".msixbundle") }
$latestWingetMsixBundle = $latestWingetMsixBundleUri.Split("/")[-1]

Write-Host "Downloading winget package..."
Invoke-WebRequest -Uri $latestWingetMsixBundleUri -OutFile "./$latestWingetMsixBundle"

Write-Host "Installing winget package..."
Add-AppxPackage -Path "./$latestWingetMsixBundle"

Write-Host "Cleaning up..."
Remove-Item "./$latestWingetMsixBundle"

Write-Host "winget installation completed. Close and reopen PowerShell and try 'winget --version' to verify."
