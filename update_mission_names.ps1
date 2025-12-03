$oldMap = Read-Host "Enter the old map name (e.g., mvm_sequoia_rc4): "
$newMap = Read-Host "Enter the new map name (e.g., mvm_sequoia_rc8): "

Get-ChildItem -File -Filter '*.pop' | Rename-Item -NewName { $_.Name -replace [regex]::Escape($oldMap), $newMap }
