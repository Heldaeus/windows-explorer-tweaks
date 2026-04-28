function Get-WindowsActivationState {
    # LicenseStatus 1 = Licensed/Activated. Querying SoftwareLicensingProduct is slow
    # (wakes the Software Protection Platform service), so the menu fetches this once
    # upfront and caches it rather than re-querying on every redraw.
    $status = (Get-CimInstance SoftwareLicensingProduct -Filter "Name like 'Windows%' and PartialProductKey is not null" -ErrorAction SilentlyContinue).LicenseStatus
    if ($status -eq 1) { 'Activated' } else { 'Not activated' }
}
