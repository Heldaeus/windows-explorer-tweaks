# HKLM (HKEY_LOCAL_MACHINE) stores settings that apply to every user on the machine.
# Writing here requires administrator rights — which is why this script prompts for
# elevation if it isn't already running as admin.
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    $me = if ($PSCommandPath) { $PSCommandPath } else { $MyInvocation.MyCommand.Path }
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$me`"" -Verb RunAs
    exit
}

# Removing HideRecommendedSection restores the default (section visible).
# An empty Policies\Explorer key is harmless, so we don't need to clean it up —
# Windows ignores keys that contain no values it recognises.
$key = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer'
if (Test-Path $key) {
    Remove-ItemProperty $key -Name 'HideRecommendedSection' -ErrorAction SilentlyContinue
}
Write-Host 'Visible: Recommended section'

Stop-Process -Name explorer -Force
Start-Process explorer
