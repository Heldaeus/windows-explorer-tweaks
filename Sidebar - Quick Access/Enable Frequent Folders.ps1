# Re-enable frequent folder suggestions in Quick Access.
# Windows tracks recently visited folders and surfaces them automatically when ShowFrequent
# is absent (the default). Removing the value restores that behaviour.
# Note: folders that were unpinned while this was disabled won't reappear on their own —
# you'll need to visit them again or re-pin them by right-clicking and choosing
# "Pin to Quick access".
Remove-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer' -Name ShowFrequent -ErrorAction SilentlyContinue
Write-Host "Frequent folders re-enabled. Previously unpinned folders will not return automatically."
Write-Host "Re-pin any folders you want back by right-clicking them and choosing 'Pin to Quick access'."
