param([string]$Path)
$text = Get-Content $Path -Raw

# 1. Clean the file of previous refactor comments so it doesn't stack infinitely
$cleanText = $text -replace '(?s)^\/\* Refactor Iteration \d+ \*\/\n', ''

# 2. Add the new iteration
$count = if (Test-Path "$Path.count") { [int](Get-Content "$Path.count") } else { 1 }
$newText = "/* Refactor Iteration $count */`n" + $cleanText.ToUpper()

Set-Content $Path -Value $newText -Encoding UTF8
Set-Content "$Path.count" ($count + 1)