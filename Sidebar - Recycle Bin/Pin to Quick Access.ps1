# The Recycle Bin can appear in two distinct places in the Explorer sidebar:
#   1. Pinned in the Quick Access section (top area, among your pinned folders)
#   2. As a standalone entry at the very bottom of the sidebar (its default position)
# This script adds it to Quick Access (#1) and hides the standalone bottom entry (#2)
# so it doesn't show up twice.

# Shell.Application is a COM object that exposes the live Explorer shell. Using it lets
# us invoke context-menu verbs programmatically, just like a right-click would.
$shell = New-Object -ComObject Shell.Application

# Navigate to the Recycle Bin as a shell namespace folder so we can access its verbs.
$rb = $shell.Namespace("shell:RecycleBinFolder")

# "Pin to Quick access" is a context-menu verb. Calling DoIt() is equivalent to
# right-clicking the Recycle Bin in Explorer and selecting that menu item.
$pin = $rb.Self.Verbs() | Where-Object { $_.Name -eq 'Pin to &Quick access' } | Select-Object -First 1
if ($pin) { $pin.DoIt() } else { Write-Host "Pin verb not found."; exit 1 }

# The Recycle Bin's CLSID — its registered identifier in the Windows shell namespace.
# Setting System.IsPinnedToNameSpaceTree to 0 hides the standalone bottom-of-sidebar
# entry, leaving only the Quick Access pin visible.
$key = 'HKCU:\Software\Classes\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}'
if (-not (Test-Path $key)) { New-Item -Path $key -Force | Out-Null }
Set-ItemProperty -Path $key -Name 'System.IsPinnedToNameSpaceTree' -Value 0 -Type DWord

Stop-Process -Name explorer -Force
Start-Process explorer
