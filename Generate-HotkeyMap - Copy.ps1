$ManifestPath = "C:\Users\brigi\Documents\Jason\Scripts\Manifest.txt"
$OutputPath = "C:\Users\brigi\Documents\Jason\Scripts\All_My_Hotkeys.txt"
$Report = New-Object System.Collections.Generic.List[string]

Get-Content $ManifestPath | ForEach-Object {
    $Target = $_.Trim()
    if (Test-Path $Target) {
        $FileName = Split-Path $Target -Leaf
        # Only read lines containing hotkeys
        Select-String -Path $Target -Pattern "::" | ForEach-Object {
            $trimmed = $_.Line.Trim()
            if ($trimmed -match '(?<!^;.*)::') {
                $Report.Add("$trimmed [File: $FileName]")
            }
        }
    }
}
$Report | Sort-Object | Out-File $OutputPath -Encoding utf8