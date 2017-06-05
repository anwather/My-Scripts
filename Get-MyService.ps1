Function Get-MyService {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [string[]]$ServiceName)
    
Process {    
    try {
         $svc = Get-Service -Name $ServiceName -ErrorAction STOP
    }
    catch {
        throw $Error[0].Exception.Message
    }

    return $Svc.Status
} 
   
    #return $Svc.Status
}
