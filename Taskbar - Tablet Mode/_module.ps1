function Get-TabletTaskbarState {
    # Both values must be 1 for the feature to be fully active; either missing or 0 = Disabled.
    $tpt = (Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer' -Name TabletPostureTaskbar -ErrorAction SilentlyContinue).TabletPostureTaskbar
    $exp = (Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name ExpandableTaskbar -ErrorAction SilentlyContinue).ExpandableTaskbar
    if ($tpt -eq 1 -and $exp -eq 1) { 'Enabled' } else { 'Disabled' }
}

function Set-TabletTaskbar([bool]$enable) {
    $val = if ($enable) { 1 } else { 0 }
    Set-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer' -Name TabletPostureTaskbar -Value $val -Type DWord
    Set-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name ExpandableTaskbar -Value $val -Type DWord
}
