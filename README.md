# Explorer Sidebar Cleaner

A collection of PowerShell scripts for tweaking the Windows 11 Explorer UI, bundled into an interactive menu.

## Usage

**One-liner (run directly from PowerShell):**
```powershell
irm https://raw.githubusercontent.com/Heldaeus/explorer-sidebar-cleaner/master/_core/menu.ps1 | iex
```

Or run `Explorer Sidebar Cleaner.bat` if you have the repo cloned locally. Either way, a UAC prompt will appear automatically for the options that require administrator privileges. Each option displays its current state and toggles on selection.

## Options

| # | Option | Description |
|---|--------|-------------|
| 1 | Home & Gallery | Show or hide the Home and Gallery entries in the Explorer sidebar |
| 2 | Recent Folders | Show or hide recent folders in Quick Access |
| 3 | Default Folder | Set Explorer to open to Home or Downloads by default |
| 4 | Recycle Bin | Pin or unpin Recycle Bin from Quick Access |
| 5 | Recommended Section | Show or hide the Recommended section in the Start Menu |
| 6 | Tablet Taskbar | Enable or disable the collapsed tablet-style taskbar |

Explorer restarts automatically when you quit if any changes were made.

## Requirements

- Windows 11
- PowerShell 5.1+
- Administrator privileges (required for the Start Menu tweak)
