Function Get-MyService {
    Param($ServiceName)
    $svc = Get-Service -Name $ServiceName
    return $Svc.Status
}
