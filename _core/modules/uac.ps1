function Get-UACPasswordState {
    # ConsentPromptBehaviorAdmin: 1 = requires password, 5 = consent-only (Windows default).
    $val = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Name ConsentPromptBehaviorAdmin -ErrorAction SilentlyContinue).ConsentPromptBehaviorAdmin
    if ($val -eq 1) { 'Required' } else { 'Not required' }
}

function Set-UACPassword([bool]$require) {
    # The system UAC policy key always exists on Windows; we never need to create it.
    $val = if ($require) { 1 } else { 5 }
    Set-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Name ConsentPromptBehaviorAdmin -Value $val -Type DWord
}
