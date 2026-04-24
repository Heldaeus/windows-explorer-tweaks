Set-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name LaunchTo -Value 3 -Type DWord
Stop-Process -Name explorer -Force
Start-Process explorer
