Function Get-SystemInfo {
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true,ValueFromPipeLine=$true)]
    [string]$ComputerName, 
    [int]$TimeOut=1000)
Process {
    try {
        $session = New-CimSession –ComputerName $ComputerName –OperationTimeoutSec $TimeOut -ErrorAction STOP
    }
    catch {
        throw $Error[0].Exception.Message
    }
        $obj = [PSCustomObject]@{
        ComputerName = $ComputerName
        Drives = Get-Volume –cimsession $session 
        NetAdapters = Get-NetAdapter –cimsession $session | Select-Object –Property Name, InterfaceIndex, Status, PSComputerName
        }
        return $obj
    }
}

