$items = @{
    Home    = '{f874310e-b6b7-47dc-bc84-b9e6b38f5903}'
    Gallery = '{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}'
}

foreach ($name in $items.Keys) {
    $key = "HKCU:\Software\Classes\CLSID\$($items[$name])"
    if (-not (Test-Path $key)) { New-Item -Path $key -Force | Out-Null }
    Set-ItemProperty -Path $key -Name 'System.IsPinnedToNameSpaceTree' -Value 0 -Type DWord
    Write-Host "Hidden: $name"
}

Stop-Process -Name explorer -Force
Start-Process explorer
