# Setting both values to 0 disables tablet-mode taskbar behaviour.
# The taskbar will stay in its standard desktop layout regardless of posture changes,
# meaning it won't expand when you detach a keyboard or fold the screen flat.
Set-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer' -Name TabletPostureTaskbar -Value 0 -Type DWord
Set-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name ExpandableTaskbar -Value 0 -Type DWord

Stop-Process -Name explorer -Force
Start-Process explorer
