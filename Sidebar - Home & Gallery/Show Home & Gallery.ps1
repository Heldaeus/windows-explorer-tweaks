$items = @{
    Home    = '{f874310e-b6b7-47dc-bc84-b9e6b38f5903}'
    Gallery = '{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}'
}

foreach ($name in $items.Keys) {
    $key = "HKCU:\Software\Classes\CLSID\$($items[$name])"
    if (Test-Path $key) {
        Remove-ItemProperty -Path $key -Name 'System.IsPinnedToNameSpaceTree' -ErrorAction SilentlyContinue
        $k = Get-Item $key
        if ($k.SubKeyCount -eq 0 -and $k.ValueCount -eq 0) {
            Remove-Item -Path $key -Force
        }
    }
    Write-Host "Restored: $name"
}

Stop-Process -Name explorer -Force
Start-Process explorer
