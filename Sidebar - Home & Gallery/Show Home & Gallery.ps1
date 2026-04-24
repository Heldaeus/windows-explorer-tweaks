# These GUIDs identify the "Home" and "Gallery" entries in the Explorer sidebar.
$items = @{
    Home    = '{f874310e-b6b7-47dc-bc84-b9e6b38f5903}'
    Gallery = '{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}'
}

# To restore default visibility we remove the HKCU override rather than setting a value.
# When no per-user override exists, Explorer falls back to the system-wide defaults,
# which show both items. We also clean up the key itself if it's now empty to avoid
# leaving stale registry entries behind.
foreach ($name in $items.Keys) {
    $key = "HKCU:\Software\Classes\CLSID\$($items[$name])"
    if (Test-Path $key) {
        Remove-ItemProperty -Path $key -Name 'System.IsPinnedToNameSpaceTree' -ErrorAction SilentlyContinue
        $k = Get-Item $key
        if ($k.SubKeyCount -eq 0 -and $k.ValueCount -eq 0) {
            Remove-Item -Path $key -Force
        }
    }
    Write-Host "Restored: $name"
}

# Explorer caches its sidebar layout in memory, so registry changes don't appear until
# it restarts. Force-killing and relaunching it is the standard way to apply them.
Stop-Process -Name explorer -Force
Start-Process explorer
