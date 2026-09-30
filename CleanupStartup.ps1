Remove-ItemProperty `
    "Registry::HKEY_USERS\S-1-5-18\Software\Microsoft\Windows\CurrentVersion\Run" `
    -Name "GoogleDriveFS" `
    -ErrorAction SilentlyContinue

Remove-ItemProperty `
    "Registry::HKEY_USERS\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\Run" `
    -Name "GoogleDriveFS" `
    -ErrorAction SilentlyContinue