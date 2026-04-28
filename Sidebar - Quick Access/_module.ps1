function Get-RecentFoldersState {
    # ShowFrequent = 0 stops Windows from auto-populating Quick Access with visited folders.
    # When absent (default), frequent folders are shown automatically.
    $val = (Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer' -Name ShowFrequent -ErrorAction SilentlyContinue).ShowFrequent
    if ($val -eq 0) { 'Hidden' } else { 'Visible' }
}

function Set-RecentFolders([bool]$hide) {
    if ($hide) {
        Set-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer' -Name ShowFrequent -Value 0 -Type DWord
    } else {
        Remove-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer' -Name ShowFrequent -ErrorAction SilentlyContinue
    }
}
