param(
    [Parameter(Mandatory=$true)]
    [string]$ScriptPath
)

$IndexFile = "C:\Users\brigi\Documents\Jason\Scripts\ScriptIndex.json"

# Create index if missing
if (Test-Path $IndexFile) {

    $raw = Get-Content $IndexFile -Raw

    if ([string]::IsNullOrWhiteSpace($raw)) {

        $Index = @()

    }
    else {

        $parsed = ConvertFrom-Json $raw

        if ($parsed -is [System.Array])
        {
            $Index = $parsed
        }
        else
        {
            $Index = @($parsed)
        }
    }
}
else {

    $Index = @()

}

# Normalize path
$FullPath = (Resolve-Path $ScriptPath).Path


# Read file metadata
$file = Get-Item $FullPath


# Extract hotkeys
$hotkeys = @()

foreach ($line in Get-Content $FullPath) {

    # Actual AHK hotkey declaration
    if ($line -match '^\s*([~*$^!+#<>&\w`]+)\s*::') {

        $hotkey = $Matches[1].Trim()

        if ($hotkey -and ($hotkeys -notcontains $hotkey)) {
            $hotkeys += $hotkey
        }
    }
}


# Find existing entry
$existing = $Index |
    Where-Object path -eq $FullPath |
    Select-Object -First 1

if ($existing) {

    # Update existing
    $existing.filename = $file.Name
    $existing.modified = $file.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss")
    $existing.hotkeys = $hotkeys

}
else {

    # Assign ID
    if ($Index.Count -eq 0) {

        $NewID = 1
    
    }
    else {

        $ids = $Index |
            ForEach-Object { $_.id }

        $NewID = ($ids | Measure-Object -Maximum).Maximum + 1

    }

    $Entry = [PSCustomObject]@{
        id = $NewID
        filename = $file.Name
        path = $FullPath
        created = $file.CreationTime.ToString("yyyy-MM-dd HH:mm:ss")
        modified = $file.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss")
        hotkeys = $hotkeys
    }

    $Index += $Entry
}

@($Index) |
    ConvertTo-Json -Depth 5 |
    Set-Content $IndexFile -Encoding UTF8