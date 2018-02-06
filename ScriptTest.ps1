Function Get-MyProcess
{
[CmdletBinding()]
Param()
$x = Get-Process -Name TabTip
Write-Output "$($x.ProcessName) - write-host"
Write-Host "$($x.ProcessName) - write-output"
Write-Verbose "$($x.ProcessName) - write-verbose"
Write-Error "$($x.ProcessName) - write-error"
}

Get-MyProcess -Verbose
