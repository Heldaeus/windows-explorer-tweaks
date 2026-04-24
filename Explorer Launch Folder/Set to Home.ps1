# To restore the default launch folder (Home / Quick Access), we remove the LaunchTo
# value entirely rather than setting it to a specific number. When the value is absent,
# Windows defaults to Home — the same behaviour as explicitly setting it to 2.
# Removing is preferable to writing because it leaves no trace in the registry.
Remove-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name LaunchTo -ErrorAction SilentlyContinue

# Explorer caches its sidebar layout in memory, so registry changes don't appear until
# it restarts. Force-killing and relaunching it is the standard way to apply them.
Stop-Process -Name explorer -Force
Start-Process explorer
