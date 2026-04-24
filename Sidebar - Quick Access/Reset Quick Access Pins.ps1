# Define the folders to keep pinned. We resolve these using .NET's Environment.GetFolderPath
# rather than hardcoding paths like "C:\Users\YourName\Documents", because folder locations
# can vary by locale, OS version, and user configuration.
$keep = @(
    [Environment]::GetFolderPath('Desktop'),
    [Environment]::GetFolderPath('MyDocuments'),
    [Environment]::GetFolderPath('MyMusic'),
    [Environment]::GetFolderPath('MyPictures'),
    [Environment]::GetFolderPath('MyVideos'),
    (Join-Path $env:USERPROFILE 'Downloads')
) | ForEach-Object { $_.TrimEnd('\') }

# Shell.Application is a COM (Component Object Model) object that exposes the live
# Explorer shell. Using it lets us call context-menu actions (like "Unpin") exactly as
# if the user right-clicked in Explorer, rather than guessing at registry paths.
$shell = New-Object -ComObject Shell.Application

# This GUID is the shell namespace address for the Quick Access folder.
# You can even type "shell:::{679f85cb-0220-4080-b29b-5540cc05aab6}" into Explorer's
# address bar to navigate there directly.
$qa = $shell.Namespace("shell:::{679f85cb-0220-4080-b29b-5540cc05aab6}")

# Unpin every folder that exists on disk but isn't in our keep list.
# We use IO.Directory::Exists rather than Test-Path to skip broken pins pointing to
# deleted or renamed folders — those don't have an Unpin verb and would cause errors.
$qa.Items() | Where-Object {
    [IO.Directory]::Exists($_.Path) -and ($_.Path.TrimEnd('\') -notin $keep)
} | ForEach-Object {
    $unpin = $_.Verbs() | Where-Object { $_.Name -match 'Unpin' } | Select-Object -First 1
    if ($unpin) {
        Write-Host "Unpinning: $($_.Path)"
        $unpin.DoIt()
    }
}

# ShowFrequent = 0 disables the "Frequent folders" feature entirely, preventing Windows
# from automatically adding folders you visit often to the Quick Access section.
Set-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer' -Name ShowFrequent -Value 0 -Type DWord

Stop-Process -Name explorer -Force
Start-Process explorer
Write-Host "Done."
