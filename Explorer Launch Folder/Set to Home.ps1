Remove-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name LaunchTo -ErrorAction SilentlyContinue
Stop-Process -Name explorer -Force
Start-Process explorer
