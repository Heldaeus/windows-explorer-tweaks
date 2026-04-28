function Get-HomeGalleryState {
    # Home and Gallery each have a unique GUID Windows uses to register them as shell
    # namespace objects. Per-user visibility is controlled by HKCU\Software\Classes\CLSID
    # overrides. We count how many are hidden so we can report 'Partial' if only one is.
    $hidden = 0
    foreach ($id in @('{f874310e-b6b7-47dc-bc84-b9e6b38f5903}', '{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}')) {
        $k = "HKCU:\Software\Classes\CLSID\$id"
        if ((Test-Path $k) -and (Get-ItemProperty $k -ErrorAction SilentlyContinue).'System.IsPinnedToNameSpaceTree' -eq 0) { $hidden++ }
    }
    if ($hidden -eq 2) { 'Hidden' } elseif ($hidden -eq 0) { 'Visible' } else { 'Partial' }
}

function Set-HomeGallery([bool]$hide) {
    foreach ($id in @('{f874310e-b6b7-47dc-bc84-b9e6b38f5903}', '{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}')) {
        $k = "HKCU:\Software\Classes\CLSID\$id"
        if ($hide) {
            if (-not (Test-Path $k)) { New-Item $k -Force | Out-Null }
            Set-ItemProperty $k -Name 'System.IsPinnedToNameSpaceTree' -Value 0 -Type DWord
        } else {
            # Remove our override so Windows falls back to its defaults (visible).
            # Clean up the key entirely if empty to avoid registry clutter.
            if (Test-Path $k) {
                Remove-ItemProperty $k -Name 'System.IsPinnedToNameSpaceTree' -ErrorAction SilentlyContinue
                $ki = Get-Item $k
                if ($ki.SubKeyCount -eq 0 -and $ki.ValueCount -eq 0) { Remove-Item $k -Force }
            }
        }
    }
}
