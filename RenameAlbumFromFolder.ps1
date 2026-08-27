$file = "C:\Users\brigi\Desktop\New folder\Chamber"

$shell = New-Object -ComObject Shell.Application

$folder = $shell.Namespace((Split-Path $file))
$item = $folder.ParseName((Split-Path $file -Leaf))

0..350 | ForEach-Object {
    $name = $folder.GetDetailsOf($null, $_)
    if ($name) {
        "{0,3}: {1} = {2}" -f $_, $name, $folder.GetDetailsOf($item, $_)
    }
}