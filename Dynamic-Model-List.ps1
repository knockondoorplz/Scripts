Add-Type @"
using System;
using System.Runtime.InteropServices;

public class HotKey {
    [DllImport("user32.dll")]
    public static extern bool RegisterHotKey(IntPtr hWnd, int id, uint fsModifiers, uint vk);
}
"@

# Hotkey: Ctrl + Win + Alt + Backspace
$MOD_CTRL = 0x2
$MOD_WIN  = 0x8
$MOD_ALT  = 0x1
$VK_BACK  = 0x08

[HotKey]::RegisterHotKey([IntPtr]::Zero, 1, $MOD_CTRL -bor $MOD_WIN -bor $MOD_ALT, $VK_BACK) | Out-Null

Write-Host "Hotkey registered. Press Ctrl+Win+Alt+Backspace to select a model."

# ---- MODEL LIST (edit this section only) ----
$models = @{
    "1" = "qwen2.5-coder:3b"
    "2" = "phi3:mini"
    "3" = "gemma:2b"
    "4" = "tinyllama"
}
# ---------------------------------------------

while ($true) {
    $msg = New-Object Windows.Forms.Message
    if ([Windows.Forms.Application]::DoEvents() -or $msg.WParam -eq 1) {

        # Show menu
        Clear-Host
        Write-Host "Select a model:`n"
        foreach ($key in $models.Keys) {
            Write-Host "$key. $($models[$key])"
        }

        $choice = Read-Host "`nEnter number"

        if ($models.ContainsKey($choice)) {
            $model = $models[$choice]
            Write-Host "`nLaunching $model..."
            Start-Process "ollama" -ArgumentList "run $model"
        } else {
            Write-Host "Invalid choice."
        }
    }

    Start-Sleep -Milliseconds 50
}
