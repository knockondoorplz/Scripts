# Define your projects and paths
$projects = @{
    "biome"        = "$HOME\Documents\GitHub\Biome Simulator\Widgets\BiomeCore"
    "chrono"       = "$HOME\Documents\GitHub\Biome Simulator\Widgets\Chronolog"
    "stream"       = "$HOME\Documents\GitHub\Biome Simulator\Widgets\Omnistream"
    "ollama"       = "$HOME\Documents\GitHub\Biome Simulator\Widgets\Ollama"
    "kos"          = "$HOME\Documents\GitHub\Biome Simulator\Widgets\KnowledgeOS"
    "cog"          = "$HOME\Documents\GitHub\Biome Simulator\Widgets\Cognisphere"
    "glyph"        = "$HOME\Documents\GitHub\Biome Simulator\Widgets\Glyph Engine"
    "rain"         = "$HOME\Documents\GitHub\Biome Simulator\Widgets\Rainmanager"
    "lab"          = "$HOME\Documents\GitHub\Biome Simulator\Widgets\ThoughtLab"
    "reflect"      = "$HOME\Documents\GitHub\Biome Simulator\Widgets\ReflectionGPT"
    "hover"        = "$HOME\Documents\GitHub\Biome Simulator\Widgets\HoverExplainer"
    "jig"          = "$HOME\Documents\GitHub\Biome Simulator\Widgets\Jiggatron File Explorer"
    "totem"        = "$HOME\Documents\GitHub\Biome Simulator\Widgets\Omnitotem"
    "plasma"       = "$HOME\Documents\GitHub\Biome Simulator\Widgets\Plasma-Sprite"
}

# Where the jump file will live
$jumpFile = "$HOME\Documents\PowerShell\ProjectJumps.ps1"

# Create or overwrite the file
"### Project Jump Functions ###" | Set-Content $jumpFile

foreach ($p in $projects.GetEnumerator()) {
    $name = $p.Key
    $path = $p.Value
    "function $name { Set-Location `"$path`" }" | Add-Content $jumpFile
}

# Add dot-source to universal profile if missing
$profilePath = $PROFILE.CurrentUserAllHosts
if (-not (Test-Path $profilePath)) {
    New-Item -ItemType File -Path $profilePath -Force | Out-Null
}

$profileContent = Get-Content $profilePath -Raw
$dotLine = ". `"$jumpFile`""

if ($profileContent -notmatch [regex]::Escape($dotLine)) {
    Add-Content $profilePath "`n$dotLine"
}
