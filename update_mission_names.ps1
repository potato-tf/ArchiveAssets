$oldMap = Read-Host "Enter the old map name (e.g., mvm_sequoia_rc4): "
$newMap = Read-Host "Enter the new map name (e.g., mvm_sequoia_rc8): "

echo "Updating mission names from $oldMap to $newMap"

Get-ChildItem -File -Filter 'scripts/population/*.pop' | Rename-Item -NewName { $_.Name -replace $oldMap, $newMap }
