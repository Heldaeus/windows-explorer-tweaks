# Shell.Application is a COM object that exposes the live Explorer shell. Using it lets
# us invoke context-menu verbs programmatically, just like a right-click would.
$shell = New-Object -ComObject Shell.Application

# To unpin something from Quick Access we must access it through the Quick Access
# namespace — the "Unpin from Quick access" verb only appears on the item when viewed
# from there, not when navigating to the Recycle Bin directly.
$qa    = $shell.Namespace("shell:::{679f85cb-0220-4080-b29b-5540cc05aab6}")
$rb    = $qa.Items() | Where-Object { $_.Name -eq 'Recycle Bin' } | Select-Object -First 1
$unpin = $rb.Verbs() | Where-Object { $_.Name -match 'Unpin' } | Select-Object -First 1
if ($unpin) { $unpin.DoIt() }

# Remove the HKCU override so the sidebar reverts to the default state.
# If we left the key with IsPinnedToNameSpaceTree = 0 after unpinning, the Recycle Bin
# would be hidden entirely rather than returning to its default bottom-of-sidebar position.
$key = 'HKCU:\Software\Classes\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}'
if (Test-Path $key) {
    Remove-ItemProperty -Path $key -Name 'System.IsPinnedToNameSpaceTree' -ErrorAction SilentlyContinue
    $k = Get-Item $key
    if ($k.SubKeyCount -eq 0 -and $k.ValueCount -eq 0) { Remove-Item -Path $key -Force }
}

Stop-Process -Name explorer -Force
Start-Process explorer
