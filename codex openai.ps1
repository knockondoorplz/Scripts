Get-ChildItem "$env:USERPROFILE\AppData\Local","$env:USERPROFILE\AppData\Roaming" -Recurse -File -ErrorAction SilentlyContinue |
Where-Object { $_.FullName -match 'codex|openai' } |
Select-Object FullName, Length, LastWriteTime |
Sort-Object LastWriteTime -Descending