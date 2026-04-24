# Windows tracks what appears in the Explorer sidebar via the shell namespace.
# Each sidebar item has a unique identifier called a GUID (Globally Unique Identifier)
# that Windows uses to register it as a shell object. These two GUIDs correspond to
# the "Home" and "Gallery" entries added to the sidebar in Windows 11.
$items = @{
    Home    = '{f874310e-b6b7-47dc-bc84-b9e6b38f5903}'
    Gallery = '{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}'
}

# HKCU\Software\Classes\CLSID lets us override system-registered shell objects per-user,
# without touching other accounts or requiring admin rights.
# Setting System.IsPinnedToNameSpaceTree to 0 tells Explorer to hide the item from
# the navigation pane. A value of 1 (or the key being absent) means visible.
foreach ($name in $items.Keys) {
    $key = "HKCU:\Software\Classes\CLSID\$($items[$name])"
    if (-not (Test-Path $key)) { New-Item -Path $key -Force | Out-Null }
    Set-ItemProperty -Path $key -Name 'System.IsPinnedToNameSpaceTree' -Value 0 -Type DWord
    Write-Host "Hidden: $name"
}

# Explorer caches its sidebar layout in memory, so registry changes don't appear until
# it restarts. Force-killing and relaunching it is the standard way to apply them.
Stop-Process -Name explorer -Force
Start-Process explorer
