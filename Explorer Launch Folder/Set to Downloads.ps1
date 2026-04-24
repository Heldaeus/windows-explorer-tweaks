# The LaunchTo registry value controls which folder Explorer opens when you launch it.
# Possible values:
#   1 = This PC
#   2 = Quick Access / Home  (the Windows default when the value is absent)
#   3 = Downloads
# Setting it to 3 makes every new Explorer window open directly to Downloads.
Set-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name LaunchTo -Value 3 -Type DWord

# Explorer caches its sidebar layout in memory, so registry changes don't appear until
# it restarts. Force-killing and relaunching it is the standard way to apply them.
Stop-Process -Name explorer -Force
Start-Process explorer
