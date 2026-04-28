function Get-RecommendedSectionState {
    # HideRecommendedSection lives in HKLM\Policies — the Group Policy enforcement hive.
    # Windows treats values here as enforced configuration rather than preferences.
    $val = (Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer' -Name HideRecommendedSection -ErrorAction SilentlyContinue).HideRecommendedSection
    if ($val -eq 1) { 'Hidden' } else { 'Visible' }
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
