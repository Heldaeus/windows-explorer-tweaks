# These two registry values work together to enable the tablet-mode expandable taskbar.
#
# TabletPostureTaskbar: tells Windows to switch taskbar behaviour when a tablet posture
#   is detected (e.g. detaching a keyboard or folding a 2-in-1 flat).
#
# ExpandableTaskbar: allows the taskbar to grow and shrink based on the current posture,
#   showing larger touch targets in tablet mode and collapsing in desktop mode.
#
# Both must be set to 1 for the feature to activate — setting only one has no effect.
Set-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer' -Name TabletPostureTaskbar -Value 1 -Type DWord
Set-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name ExpandableTaskbar -Value 1 -Type DWord

Stop-Process -Name explorer -Force
Start-Process explorer
