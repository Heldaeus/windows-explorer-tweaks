if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    $me = if ($PSCommandPath) { $PSCommandPath } else { $MyInvocation.MyCommand.Path }
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$me`"" -Verb RunAs
    exit
}

$key = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer'
if (Test-Path $key) {
    Remove-ItemProperty $key -Name 'HideRecommendedSection' -ErrorAction SilentlyContinue
}
Write-Host 'Visible: Recommended section'

Stop-Process -Name explorer -Force
Start-Process explorer
