# ── Elevation ─────────────────────────────────────────────────────────────────
# Some settings (e.g. hiding the Start Menu Recommended section) live in HKLM
# (HKEY_LOCAL_MACHINE), which requires administrator rights to write. Rather than
# failing silently mid-session, we check upfront and re-launch the whole script
# elevated so everything works without per-action prompts.
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    $me = if ($PSCommandPath) { $PSCommandPath } else { $MyInvocation.MyCommand.Path }
    try {
        if ($me) {
            # Normal case: re-launch this file elevated using -Verb RunAs, which triggers
            # the Windows UAC (User Account Control) prompt.
            Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$me`"" -Verb RunAs -ErrorAction Stop
        } else {
            # Fallback for when the script was piped in via "irm <url> | iex" and therefore
            # has no path on disk. In that case $PSCommandPath is null and we can't use -File,
            # so we re-fetch the script from GitHub and run it with -Command instead.
            $url = 'https://raw.githubusercontent.com/Heldaeus/windows-explorer-tweaks/master/_core/menu.ps1'
            Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"irm '$url' | iex`"" -Verb RunAs -ErrorAction Stop
        }
    } catch {
        Write-Host "Elevation failed: $_" -ForegroundColor Red
        Read-Host 'Press Enter to close'
    }
    exit
}

# ── State detectors ──────────────────────────────────────────────────────────
# Each function reads live registry or shell state and returns a short human-readable
# label. The menu calls these before every redraw so it always shows the current truth,
# even if something was changed outside this tool.

function Get-HomeGalleryState {
    # Home and Gallery each have a unique GUID (Globally Unique Identifier) that Windows
    # uses to register them as shell namespace objects. Per-user visibility is controlled
    # by overrides in HKCU\Software\Classes\CLSID. We count how many of the two are
    # hidden so we can report a "Partial" state if only one has been overridden.
    $hidden = 0
    foreach ($id in @('{f874310e-b6b7-47dc-bc84-b9e6b38f5903}', '{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}')) {
        $k = "HKCU:\Software\Classes\CLSID\$id"
        if ((Test-Path $k) -and (Get-ItemProperty $k -ErrorAction SilentlyContinue).'System.IsPinnedToNameSpaceTree' -eq 0) { $hidden++ }
    }
    if ($hidden -eq 2) { 'Hidden' } elseif ($hidden -eq 0) { 'Visible' } else { 'Partial' }
}

function Get-RecentFoldersState {
    # ShowFrequent = 0 means Windows will not auto-populate Quick Access with visited folders.
    # When the value is absent (the default), frequent folders are shown automatically.
    $val = (Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer' -Name ShowFrequent -ErrorAction SilentlyContinue).ShowFrequent
    if ($val -eq 0) { 'Hidden' } else { 'Visible' }
}

function Get-DefaultFolderState {
    # LaunchTo controls which folder Explorer opens on launch.
    # 3 = Downloads; any other value (or absent) defaults to Home / Quick Access.
    $val = (Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name LaunchTo -ErrorAction SilentlyContinue).LaunchTo
    if ($val -eq 3) { 'Downloads' } else { 'Home' }
}

function Get-RecommendedSectionState {
    # HideRecommendedSection lives in HKLM\Policies — the Group Policy enforcement hive.
    # Windows components treat values here as enforced configuration rather than preferences.
    # A value of 1 suppresses the Recommended section in the Start Menu for all users.
    $val = (Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer' -Name HideRecommendedSection -ErrorAction SilentlyContinue).HideRecommendedSection
    if ($val -eq 1) { 'Hidden' } else { 'Visible' }
}

function Get-TabletTaskbarState {
    # Both values must be 1 for the feature to be fully active; we report Disabled if
    # either is missing or 0.
    $tpt = (Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer' -Name TabletPostureTaskbar -ErrorAction SilentlyContinue).TabletPostureTaskbar
    $exp = (Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name ExpandableTaskbar -ErrorAction SilentlyContinue).ExpandableTaskbar
    if ($tpt -eq 1 -and $exp -eq 1) { 'Enabled' } else { 'Disabled' }
}

function Get-RecycleBinState {
    # We check whether "Recycle Bin" appears among the items in the Quick Access namespace
    # using Shell.Application (a COM object) rather than reading the registry, because
    # the registry and the live shell can briefly disagree after a verb action.
    $qa = (New-Object -ComObject Shell.Application).Namespace("shell:::{679f85cb-0220-4080-b29b-5540cc05aab6}")
    if ($qa -and ($qa.Items() | Where-Object { $_.Name -eq 'Recycle Bin' })) { 'Pinned' } else { 'Unpinned' }
}

# ── Actions ───────────────────────────────────────────────────────────────────
# Each function accepts a parameter describing the desired end-state and applies the
# appropriate registry changes. The menu loop decides what to call; these just do it.

function Set-HomeGallery([bool]$hide) {
    foreach ($id in @('{f874310e-b6b7-47dc-bc84-b9e6b38f5903}', '{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}')) {
        $k = "HKCU:\Software\Classes\CLSID\$id"
        if ($hide) {
            if (-not (Test-Path $k)) { New-Item $k -Force | Out-Null }
            Set-ItemProperty $k -Name 'System.IsPinnedToNameSpaceTree' -Value 0 -Type DWord
        } else {
            # Restoring visibility means removing our override so Windows falls back to its
            # own defaults (visible). We also clean up empty keys to avoid registry clutter.
            if (Test-Path $k) {
                Remove-ItemProperty $k -Name 'System.IsPinnedToNameSpaceTree' -ErrorAction SilentlyContinue
                $ki = Get-Item $k
                if ($ki.SubKeyCount -eq 0 -and $ki.ValueCount -eq 0) { Remove-Item $k -Force }
            }
        }
    }
}

function Set-RecentFolders([bool]$hide) {
    if ($hide) {
        Set-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer' -Name ShowFrequent -Value 0 -Type DWord
    } else {
        Remove-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer' -Name ShowFrequent -ErrorAction SilentlyContinue
    }
}

function Set-DefaultFolder([string]$target) {
    if ($target -eq 'Downloads') {
        Set-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name LaunchTo -Value 3 -Type DWord
    } else {
        Remove-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name LaunchTo -ErrorAction SilentlyContinue
    }
}

function Set-RecommendedSection([bool]$hide) {
    $key = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer'
    if ($hide) {
        if (-not (Test-Path $key)) { New-Item $key -Force | Out-Null }
        Set-ItemProperty $key -Name 'HideRecommendedSection' -Value 1 -Type DWord
    } else {
        if (Test-Path $key) {
            Remove-ItemProperty $key -Name 'HideRecommendedSection' -ErrorAction SilentlyContinue
        }
    }
}

function Set-TabletTaskbar([bool]$enable) {
    $val = if ($enable) { 1 } else { 0 }
    Set-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer' -Name TabletPostureTaskbar -Value $val -Type DWord
    Set-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name ExpandableTaskbar -Value $val -Type DWord
}

function Set-RecycleBin([bool]$pin) {
    $shell   = New-Object -ComObject Shell.Application
    $hkcuKey = 'HKCU:\Software\Classes\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}'
    if ($pin) {
        # Invoke the "Pin to Quick access" verb via the shell — equivalent to right-clicking
        # the Recycle Bin in Explorer and selecting that option.
        $v = $shell.Namespace("shell:RecycleBinFolder").Self.Verbs() | Where-Object { $_.Name -eq 'Pin to &Quick access' } | Select-Object -First 1
        if ($v) { $v.DoIt() }
        # Hide the default standalone sidebar entry so the Recycle Bin only appears once,
        # in the Quick Access section rather than at the bottom of the sidebar.
        if (-not (Test-Path $hkcuKey)) { New-Item $hkcuKey -Force | Out-Null }
        Set-ItemProperty $hkcuKey -Name 'System.IsPinnedToNameSpaceTree' -Value 0 -Type DWord
    } else {
        # The "Unpin" verb is only available when accessing the item through the Quick Access
        # namespace — it doesn't appear when navigating to the Recycle Bin directly.
        $rb = $shell.Namespace("shell:::{679f85cb-0220-4080-b29b-5540cc05aab6}").Items() | Where-Object { $_.Name -eq 'Recycle Bin' } | Select-Object -First 1
        if ($rb) {
            $v = $rb.Verbs() | Where-Object { $_.Name -match 'Unpin' } | Select-Object -First 1
            if ($v) { $v.DoIt() }
        }
        # Remove the HKCU override so the Recycle Bin returns to its default sidebar
        # position. Leaving IsPinnedToNameSpaceTree = 0 would hide it entirely.
        if (Test-Path $hkcuKey) {
            Remove-ItemProperty $hkcuKey -Name 'System.IsPinnedToNameSpaceTree' -ErrorAction SilentlyContinue
            $k = Get-Item $hkcuKey
            if ($k.SubKeyCount -eq 0 -and $k.ValueCount -eq 0) { Remove-Item $hkcuKey -Force }
        }
    }
}

# ── Menu loop ─────────────────────────────────────────────────────────────────

$changed = $false
$running = $true

try {

while ($running) {
    # Read all state fresh every iteration so the display is always accurate, even if
    # something was changed outside this tool while it was open.
    $hg = Get-HomeGalleryState
    $rf = Get-RecentFoldersState
    $df = Get-DefaultFolderState
    $rb = Get-RecycleBinState
    $rs = Get-RecommendedSectionState
    $tt = Get-TabletTaskbarState

    Clear-Host
    Write-Host ""
    Write-Host "  Explorer Sidebar Cleaner"
    Write-Host "  ------------------------------------------"
    Write-Host ""
    Write-Host ("  [1]  Home & Gallery       " + $hg)
    Write-Host ("  [2]  Recent Folders       " + $rf)
    Write-Host ("  [3]  Default Folder       " + $df)
    Write-Host ("  [4]  Recycle Bin          " + $rb)
    Write-Host ("  [5]  Recommended Section  " + $rs)
    Write-Host ("  [6]  Tablet Taskbar       " + $tt)
    Write-Host ""
    Write-Host "  [Q]  Quit"
    Write-Host ""

    $choice = (Read-Host "  Select").Trim().ToUpper()

    # Each case reads the current state and flips it, so pressing a number always
    # does the opposite of whatever is active right now.
    switch ($choice) {
        '1' {
            if ($hg -eq 'Hidden') { Set-HomeGallery $false } else { Set-HomeGallery $true }
            $changed = $true
        }
        '2' {
            if ($rf -eq 'Visible') { Set-RecentFolders $true } else { Set-RecentFolders $false }
            $changed = $true
        }
        '3' {
            if ($df -eq 'Downloads') { Set-DefaultFolder 'Home' } else { Set-DefaultFolder 'Downloads' }
            $changed = $true
        }
        '4' {
            if ($rb -eq 'Pinned') { Set-RecycleBin $false } else { Set-RecycleBin $true }
            $changed = $true
        }
        '5' {
            if ($rs -eq 'Hidden') { Set-RecommendedSection $false } else { Set-RecommendedSection $true }
            $changed = $true
        }
        '6' {
            if ($tt -eq 'Enabled') { Set-TabletTaskbar $false } else { Set-TabletTaskbar $true }
            $changed = $true
        }
        'Q' { $running = $false }
    }
}

} catch {
    Write-Host ""
    Write-Host "  Error: $_" -ForegroundColor Red
    Read-Host '  Press Enter to close'
    exit 1
}

# Only restart Explorer if something actually changed. Restarting it unnecessarily
# would close any open folder windows the user had open.
if ($changed) {
    Stop-Process -Name explorer -Force
    Start-Process explorer
}
