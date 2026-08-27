# Get all AHK files, excluding the ones we don't want
$files = Get-ChildItem -Path "C:\Users\brigi\Documents\Jason\Scripts\*.ahk" -Exclude "MyCommands.ahk", "Inspector.ahk"

$output = foreach ($file in $files) {
    # Read the file content
    $content = Get-Content $file.FullName
    
    foreach ($line in $content) {
        # Only look for lines that contain a hotkey (::) 
        # But filter out lines that have := (variables) or are just code
        if ($line -match '::' -and $line -notmatch ':=') {
            # Extract just the hotkey part (everything before the first ::)
            $hotkey = $line.Split('::')[0].Trim()
            
            # If the hotkey is valid, print: Hotkey:: Filename
            if ($hotkey -ne "") {
                "$hotkey:: $($file.Name)"
            }
        }
    }
}

# Save to your index file
$output | Select-Object -Unique | Set-Content "C:\Users\brigi\Documents\Jason\Scripts\All_My_Hotkeys.txt"