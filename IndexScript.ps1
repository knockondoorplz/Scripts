param(
    [Parameter(Mandatory=$true)]
    [string]$ScriptPath
)

$IndexFile = "C:\Users\brigi\Documents\Jason\Scripts\ScriptIndex.json"

# ==========================================================
# Load existing index
# ==========================================================

if (Test-Path $IndexFile) {

    $raw = Get-Content $IndexFile -Raw

    if ([string]::IsNullOrWhiteSpace($raw)) {
        $Index = @()
    }
    else {
        $parsed = ConvertFrom-Json $raw

        if ($parsed -is [System.Array]) {
            $Index = $parsed
        }
        else {
            $Index = @($parsed)
        }
    }
}
else {
    $Index = @()
}


# ==========================================================
# Normalize path
# ==========================================================

$FullPath = (Resolve-Path $ScriptPath).Path


# ==========================================================
# Read file metadata
# ==========================================================

$file = Get-Item $FullPath


# ==========================================================
# Read source
# ==========================================================

$Lines = Get-Content $FullPath


# ==========================================================
# Extract hotkeys + bindings
# ==========================================================

$hotkeys = @()
$bindings = @()

foreach ($line in $Lines) {

    # ------------------------------------------------------
    # AHK hotkey declaration
    #
    # Examples:
    #
    # ^#!p::OpenAnywherePowerShell()
    # ^+j::ShowCommands()
    # ^#!p::Run("powershell.exe")
    # ^#!p::{
    # ------------------------------------------------------

    if ($line -match '^\s*([~*$^!+#<>&\w`]+)\s*::\s*(.*)$') {

        $hotkey = $Matches[1].Trim()
        $action = $Matches[2].Trim()

        if (!$hotkey) {
            continue
        }

        # Keep legacy hotkey list
        if ($hotkeys -notcontains $hotkey) {
            $hotkeys += $hotkey
        }


        # --------------------------------------------------
        # Determine binding type
        # --------------------------------------------------

        $binding = [ordered]@{
            hotkey = $hotkey
            function = $null
            type = "unknown"
        }


        # --------------------------------------------------
        # Block hotkey
        # --------------------------------------------------

        if ($action -match '^\{') {

            $binding.type = "block"
        }


        # --------------------------------------------------
        # Direct function call
        #
        # Example:
        # ^#!p::OpenAnywherePowerShell()
        #
        # Captures:
        # OpenAnywherePowerShell
        # --------------------------------------------------

        elseif ($action -match '^\s*([A-Za-z_][A-Za-z0-9_]*)\s*\(') {

            $binding.function = $Matches[1]
            $binding.type = "function"
        }


        # --------------------------------------------------
        # Other inline action
        # --------------------------------------------------

        else {

            $binding.type = "inline"
        }


        $bindings += [PSCustomObject]$binding
    }
}


# ==========================================================
# Find existing entry
# ==========================================================

$existing = $Index |
    Where-Object path -eq $FullPath |
    Select-Object -First 1


if ($existing) {

    # ======================================================
    # Update existing
    # ======================================================

    $existing.filename = $file.Name
    $existing.modified = $file.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss")
    $existing.hotkeys = $hotkeys
    $existing | Add-Member -MemberType NoteProperty -Name "bindings" -Value $bindings -Force

}
else {

    # ======================================================
    # Assign ID
    # ======================================================

    if ($Index.Count -eq 0) {
        $NewID = 1
    }
    else {

        $ids = $Index |
            ForEach-Object { $_.id }

        $NewID = ($ids | Measure-Object -Maximum).Maximum + 1
    }


    # ======================================================
    # Create entry
    # ======================================================

    $Entry = [PSCustomObject]@{
        id = $NewID
        filename = $file.Name
        path = $FullPath
        created = $file.CreationTime.ToString("yyyy-MM-dd HH:mm:ss")
        modified = $file.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss")
        hotkeys = $hotkeys
        bindings = $bindings
    }

    $Index += $Entry
}


# ==========================================================
# Write index
# ==========================================================
Write-Host "Bindings found: $($bindings.Count)"

@($Index) |
    ConvertTo-Json -Depth 10 |
    Set-Content $IndexFile -Encoding UTF8