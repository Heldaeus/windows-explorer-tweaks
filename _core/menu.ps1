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
            # has no path on disk. Re-fetch the script from GitHub and run it elevated.
            $url = 'https://raw.githubusercontent.com/Heldaeus/windows-explorer-tweaks/master/_core/menu.ps1'
            Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"irm '$url' | iex`"" -Verb RunAs -ErrorAction Stop
        }
    } catch {
        Write-Host "Elevation failed: $_" -ForegroundColor Red
        Read-Host 'Press Enter to close'
    }
    exit
}

# ── Modules ───────────────────────────────────────────────────────────────────
# Load state detectors and action functions from each feature's own folder.
# When running from a file on disk, dot-source by path. When piped in via
# irm | iex (no file on disk), fetch each module from GitHub and evaluate it.

if ($PSCommandPath) {
    $root = Split-Path (Split-Path $PSCommandPath -Parent) -Parent
    . "$root\Sidebar - Home & Gallery\_module.ps1"
    . "$root\Sidebar - Quick Access\_module.ps1"
    . "$root\Explorer Launch Folder\_module.ps1"
    . "$root\Sidebar - Recycle Bin\_module.ps1"
    . "$root\Start Menu\_module.ps1"
    . "$root\Taskbar - Tablet Mode\_module.ps1"
    . "$root\_core\modules\edge.ps1"
    . "$root\_core\modules\activation.ps1"
    . "$root\_core\modules\uac.ps1"
} else {
    $repoUrl = 'https://raw.githubusercontent.com/Heldaeus/windows-explorer-tweaks/master'
    # URL-encode each path segment so folder names with spaces/ampersands resolve correctly.
    function _EncodeUrl([string]$p) {
        ($p -split '[/\\]' | ForEach-Object { [Uri]::EscapeDataString($_) }) -join '/'
    }
    iex (irm "$repoUrl/$(_EncodeUrl 'Sidebar - Home & Gallery/_module.ps1')")
    iex (irm "$repoUrl/$(_EncodeUrl 'Sidebar - Quick Access/_module.ps1')")
    iex (irm "$repoUrl/$(_EncodeUrl 'Explorer Launch Folder/_module.ps1')")
    iex (irm "$repoUrl/$(_EncodeUrl 'Sidebar - Recycle Bin/_module.ps1')")
    iex (irm "$repoUrl/$(_EncodeUrl 'Start Menu/_module.ps1')")
    iex (irm "$repoUrl/$(_EncodeUrl 'Taskbar - Tablet Mode/_module.ps1')")
    iex (irm "$repoUrl/_core/modules/edge.ps1")
    iex (irm "$repoUrl/_core/modules/activation.ps1")
    iex (irm "$repoUrl/_core/modules/uac.ps1")
}

# ── Menu loop ─────────────────────────────────────────────────────────────────

$changed = $false
$running = $true

# Querying SoftwareLicensingProduct via CIM is slow (it wakes the Software Protection
# Platform service), so we fetch it once upfront rather than on every menu redraw.
$wa = Get-WindowsActivationState

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
    $eg = Get-EdgeState
    $up = Get-UACPasswordState

    Clear-Host
    Write-Host ""
    Write-Host "  Windows Explorer Tweaks"
    Write-Host "  ------------------------------------------"
    Write-Host ""
    Write-Host ("  [1]  Home & Gallery       " + $hg)
    Write-Host ("  [2]  Recent Folders       " + $rf)
    Write-Host ("  [3]  Default Folder       " + $df)
    Write-Host ("  [4]  Recycle Bin          " + $rb)
    Write-Host ("  [5]  Recommended Section  " + $rs)
    Write-Host ("  [6]  Tablet Taskbar       " + $tt)
    Write-Host ("  [7]  Microsoft Edge       " + $eg)
    Write-Host ("  [8]  Windows Activation   " + $wa)
    Write-Host ("  [9]  UAC Password         " + $up)
    Write-Host ""
    Write-Host "  [R]  Restart Explorer"
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
        '7' {
            # Launch EdgeRemover in a new window. We're already elevated so the child
            # process inherits admin rights. EdgeRemover runs its own TUI so we open
            # it separately rather than embedding it here.
            Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"iex(irm 'https://cdn.jsdelivr.net/gh/he3als/EdgeRemover@main/get.ps1')`""
        }
        '8' {
            # -Wait blocks until the MAS window closes so we re-query only after it's
            # actually done, not immediately after launch when nothing has changed yet.
            Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"irm https://get.activated.win | iex`"" -Wait
            $wa = Get-WindowsActivationState
        }
        '9' {
            if ($up -eq 'Required') { Set-UACPassword $false } else { Set-UACPassword $true }
            $changed = $true
        }
        'R' {
            Stop-Process -Name explorer -Force
            Stop-Process -Name StartMenuExperienceHost -Force -ErrorAction SilentlyContinue
            Start-Process explorer
            $changed = $false
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

# Only restart Explorer if something actually changed. Restarting unnecessarily
# would close any open folder windows the user had open.
if ($changed) {
    Stop-Process -Name explorer -Force
    Stop-Process -Name StartMenuExperienceHost -Force -ErrorAction SilentlyContinue
    Start-Process explorer
}
