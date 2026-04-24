# HKLM (HKEY_LOCAL_MACHINE) stores settings that apply to every user on the machine.
# Writing here requires administrator rights — which is why this script prompts for
# elevation if it isn't already running as admin.
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    $me = if ($PSCommandPath) { $PSCommandPath } else { $MyInvocation.MyCommand.Path }
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$me`"" -Verb RunAs
    exit
}

# The \Policies subkey is where Group Policy-style settings live. Windows components
# check this location and treat its values as enforced configuration — stronger than
# regular user preferences stored elsewhere in the registry.
# HideRecommendedSection = 1 instructs the Start Menu to omit the "Recommended" area.
$key = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer'
if (-not (Test-Path $key)) { New-Item $key -Force | Out-Null }
Set-ItemProperty $key -Name 'HideRecommendedSection' -Value 1 -Type DWord
Write-Host 'Hidden: Recommended section'

Stop-Process -Name explorer -Force
Start-Process explorer
