<#
    list_vsts.ps1

    This PowerShell script scans common VST plug‑in folders on a Windows system
    and generates a plain‑text report of all DLL and VST3 files it finds.

    The script writes the results to a file called `vst_dir_list.txt` in the
    same directory as the script. If you want to add or remove search folders,
    edit the `$scanDirs` array below.

    Usage:
      1. Save this script to a folder on your Windows machine.
      2. Right‑click the script and choose “Run with PowerShell.”
      3. When the script finishes, open the generated `vst_dir_list.txt`
         (in the same folder) to view your plug‑in inventory. You can share
         this file with your AI assistant so it knows which plug‑ins are
         already installed.
#>

# List of directories to search.  Feel free to modify this list to match
# your system.  Typical VST locations have been included by default.
$scanDirs = @(
    "C:\\Program Files\\VSTPlugins",
    "C:\\Program Files\\Common Files\\VST3",
    "C:\\Program Files\\Steinberg\\VSTPlugins",
    "C:\\Program Files (x86)\\VSTPlugins",
    "C:\\Program Files (x86)\\Common Files\\VST3",
    "C:\\Program Files (x86)\\Steinberg\\VSTPlugins",
    "$env:USERPROFILE\\Documents\\VSTPlugins",
    "$env:USERPROFILE\\Documents\\Common Files\\VST3",
    "$env:USERPROFILE\\VSTPlugins",
    "$env:USERPROFILE\\Common Files\\VST3"
    # Additional directories specific to Image‑Line FL Studio installations and CLAP plug‑ins
    "C:\\Program Files (x86)\\Image-Line\\FL Studio 2025\\Plugins\\Fruity\\Effects",
    "C:\\Program Files (x86)\\Image-Line\\FL Studio 2025\\Plugins\\Fruity\\Generators",
    "C:\\Program Files (x86)\\Image-Line\\FL Studio 2025\\Plugins\\VST",
    "C:\\Program Files (x86)\\Image-Line\\FL Studio 2024\\Plugins\\VST",
    "C:\\Program Files (x86)\\Common Files\\Steinberg\\VST2",
    "C:\\Program Files\\Common Files\\VST2",
    "C:\\Program Files\\Common Files\\Steinberg\\VST2",
    "C:\\Program Files (x86)\\Common Files\\CLAP",
    "C:\\Program Files\\Common Files\\CLAP"
)

# Results will be stored in this array
$results = @()

foreach ($dir in $scanDirs) {
    if (Test-Path -LiteralPath $dir) {
        # Find DLL files
        $dllFiles = Get-ChildItem -LiteralPath $dir -Include *.dll -Recurse -ErrorAction SilentlyContinue
        # Find VST3 plug‑ins
        $vst3Files = Get-ChildItem -LiteralPath $dir -Include *.vst3 -Recurse -ErrorAction SilentlyContinue

        foreach ($file in $dllFiles + $vst3Files) {
            $results += $file.FullName
        }
    }
}

# Remove duplicates and sort alphabetically
$results = $results | Sort-Object -Unique

# Determine output path (script directory)
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$outputPath = Join-Path -Path $scriptDir -ChildPath "vst_dir_list.txt"

# Write the list to disk
$results | Out-File -FilePath $outputPath -Encoding UTF8

Write-Host "Found $($results.Count) plug‑in files." -ForegroundColor Green
Write-Host "Inventory saved to $outputPath" -ForegroundColor Green