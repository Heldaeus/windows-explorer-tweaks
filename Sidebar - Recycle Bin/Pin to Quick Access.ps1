$shell = New-Object -ComObject Shell.Application
$rb    = $shell.Namespace("shell:RecycleBinFolder")

# Pin to Quick Access (appears after existing pinned folders)
$pin = $rb.Self.Verbs() | Where-Object { $_.Name -eq 'Pin to &Quick access' } | Select-Object -First 1
if ($pin) { $pin.DoIt() } else { Write-Host "Pin verb not found."; exit 1 }

# Hide the duplicate entry at the bottom of the sidebar
$key = 'HKCU:\Software\Classes\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}'
if (-not (Test-Path $key)) { New-Item -Path $key -Force | Out-Null }
Set-ItemProperty -Path $key -Name 'System.IsPinnedToNameSpaceTree' -Value 0 -Type DWord

Stop-Process -Name explorer -Force
Start-Process explorer
