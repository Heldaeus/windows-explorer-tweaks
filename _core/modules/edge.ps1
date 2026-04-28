function Get-EdgeState {
    # Checking the executable is faster and more reliable than querying AppX packages,
    # which vary depending on how Edge was installed (Store vs. standalone installer).
    $exe = "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe"
    if (Test-Path $exe) { 'Installed' } else { 'Not installed' }
}
