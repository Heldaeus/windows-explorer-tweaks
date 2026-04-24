# Re-enable frequent folder suggestions
Remove-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer' -Name ShowFrequent -ErrorAction SilentlyContinue
Write-Host "Frequent folders re-enabled. Previously unpinned folders will not return automatically."
Write-Host "Re-pin any folders you want back by right-clicking them and choosing 'Pin to Quick access'."
