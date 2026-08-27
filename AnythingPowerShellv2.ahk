# AnywherePowerShell v2
# Run PowerShell commands from anywhere without changing windows.

param(
    [Parameter(Mandatory=$true)]
    [string]$Command,

    [switch]$Json
)

$result = [ordered]@{
    command   = $Command
    timestamp = (Get-Date).ToString("o")
    success   = $false
    output    = ""
    error     = ""
    cwd       = (Get-Location).Path
}

try {
    $output = & powershell.exe -NoProfile -Command $Command 2>&1

    $result.output = ($output | Out-String).Trim()
    $result.success = $true
}
catch {
    $result.error = $_.Exception.Message
}

if ($Json) {
    $result | ConvertTo-Json -Depth 5
}
else {
    if ($result.success) {
        $result.output
    }
    else {
        Write-Error $result.error
    }
}