function Get-DefaultFolderState {
    # LaunchTo = 3 opens Explorer to Downloads; absent/other defaults to Home/Quick Access.
    $val = (Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name LaunchTo -ErrorAction SilentlyContinue).LaunchTo
    if ($val -eq 3) { 'Downloads' } else { 'Home' }
}

function Set-DefaultFolder([string]$target) {
    if ($target -eq 'Downloads') {
        Set-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name LaunchTo -Value 3 -Type DWord
    } else {
        Remove-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name LaunchTo -ErrorAction SilentlyContinue
    }
}
