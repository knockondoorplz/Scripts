# MoveSelectedToFolder.ps1
Add-Type -AssemblyName Microsoft.VisualBasic
$targetFolder = "H:\Jason's Files\Some !@#% Code"

$shell = New-Object -ComObject Shell.Application
$explorer = $shell.Windows() | Where-Object { $_.Document.Focused }
if ($explorer) {
    $selectedItems = $explorer.Document.SelectedItems()
    foreach ($item in $selectedItems) {
        Move-Item -LiteralPath $item.Path -Destination $targetFolder
    }
} else {
    [Microsoft.VisualBasic.Interaction]::MsgBox("No folder selected or no explorer window focused.")
}

