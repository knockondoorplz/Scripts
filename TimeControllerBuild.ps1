cd "C:\Users\brigi\Documents\GitHub\Biome Simulator.worktrees\time-controller-status-update\TimeController"

$source = ".\build\TimeController_artefacts\Release\VST3\Time Controller.vst3"
$destination = "$env:CommonProgramFiles\VST3\Time Controller.vst3"

# Preserve the old June build
if (Test-Path -LiteralPath $destination) {
    Rename-Item -LiteralPath $destination `
        -NewName "Time Controller.vst3.old-june" -Force
}

# Install the newly built bundle
Copy-Item -LiteralPath $source `
    -Destination $destination -Recurse -Force