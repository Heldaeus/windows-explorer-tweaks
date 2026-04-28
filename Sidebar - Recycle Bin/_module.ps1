function Get-RecycleBinState {
    # Use Shell.Application COM rather than the registry — the registry and the live
    # shell can briefly disagree after a verb action.
    $qa = (New-Object -ComObject Shell.Application).Namespace("shell:::{679f85cb-0220-4080-b29b-5540cc05aab6}")
    if ($qa -and ($qa.Items() | Where-Object { $_.Name -eq 'Recycle Bin' })) { 'Pinned' } else { 'Unpinned' }
}

function Set-RecycleBin([bool]$pin) {
    $shell   = New-Object -ComObject Shell.Application
    $hkcuKey = 'HKCU:\Software\Classes\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}'
    if ($pin) {
        $v = $shell.Namespace("shell:RecycleBinFolder").Self.Verbs() | Where-Object { $_.Name -eq 'Pin to &Quick access' } | Select-Object -First 1
        if ($v) { $v.DoIt() }
        # Hide the standalone sidebar entry so Recycle Bin only appears once, in Quick Access.
        if (-not (Test-Path $hkcuKey)) { New-Item $hkcuKey -Force | Out-Null }
        Set-ItemProperty $hkcuKey -Name 'System.IsPinnedToNameSpaceTree' -Value 0 -Type DWord
    } else {
        # The Unpin verb is only available via the Quick Access namespace, not the Recycle Bin directly.
        $rb = $shell.Namespace("shell:::{679f85cb-0220-4080-b29b-5540cc05aab6}").Items() | Where-Object { $_.Name -eq 'Recycle Bin' } | Select-Object -First 1
        if ($rb) {
            $v = $rb.Verbs() | Where-Object { $_.Name -match 'Unpin' } | Select-Object -First 1
            if ($v) { $v.DoIt() }
        }
        if (Test-Path $hkcuKey) {
            Remove-ItemProperty $hkcuKey -Name 'System.IsPinnedToNameSpaceTree' -ErrorAction SilentlyContinue
            $k = Get-Item $hkcuKey
            if ($k.SubKeyCount -eq 0 -and $k.ValueCount -eq 0) { Remove-Item $hkcuKey -Force }
        }
    }
}
