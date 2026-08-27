$body = @{
    active_window = "PowerShell"
    cwd = (Get-Location).Path
    question = "What should I automate next?"
    allow_automation = $true
} | ConvertTo-Json

Invoke-RestMethod `
    -Method Post `
    -Uri "http://127.0.0.1:8000/clippy/suggest" `
    -ContentType "application/json" `
    -Body $body