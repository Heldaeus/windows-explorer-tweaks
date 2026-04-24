$keep = @(
    [Environment]::GetFolderPath('Desktop'),
    [Environment]::GetFolderPath('MyDocuments'),
    [Environment]::GetFolderPath('MyMusic'),
    [Environment]::GetFolderPath('MyPictures'),
    [Environment]::GetFolderPath('MyVideos'),
    (Join-Path $env:USERPROFILE 'Downloads')
) | ForEach-Object { $_.TrimEnd('\') }

$shell = New-Object -ComObject Shell.Application
$qa    = $shell.Namespace("shell:::{679f85cb-0220-4080-b29b-5540cc05aab6}")

$qa.Items() | Where-Object {
    [IO.Directory]::Exists($_.Path) -and ($_.Path.TrimEnd('\') -notin $keep)
} | ForEach-Object {
    $unpin = $_.Verbs() | Where-Object { $_.Name -match 'Unpin' } | Select-Object -First 1
    if ($unpin) {
        Write-Host "Unpinning: $($_.Path)"
        $unpin.DoIt()
    }
}

# Prevent Windows from auto-adding frequent folders
Set-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer' -Name ShowFrequent -Value 0 -Type DWord

Stop-Process -Name explorer -Force
Start-Process explorer
Write-Host "Done."
