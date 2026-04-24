$shell = New-Object -ComObject Shell.Application

# Must access through Quick Access namespace to get the Unpin verb
$qa    = $shell.Namespace("shell:::{679f85cb-0220-4080-b29b-5540cc05aab6}")
$rb    = $qa.Items() | Where-Object { $_.Name -eq 'Recycle Bin' } | Select-Object -First 1
$unpin = $rb.Verbs() | Where-Object { $_.Name -match 'Unpin' } | Select-Object -First 1
if ($unpin) { $unpin.DoIt() }

# Remove HKCU override so sidebar reverts to default state
$key = 'HKCU:\Software\Classes\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}'
if (Test-Path $key) {
    Remove-ItemProperty -Path $key -Name 'System.IsPinnedToNameSpaceTree' -ErrorAction SilentlyContinue
    $k = Get-Item $key
    if ($k.SubKeyCount -eq 0 -and $k.ValueCount -eq 0) { Remove-Item -Path $key -Force }
}

Stop-Process -Name explorer -Force
Start-Process explorer
