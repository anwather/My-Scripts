[CmdletBinding()]
Param(
    [Parameter(Mandatory=$True,
               ValueFromPipeline=$True,
               ValueFromPipelineByPropertyName=$True)]
    [string[]]$ComputerName
    )

Process
    {
    Foreach ($computer in $computerName)
    {Write-Output $Computer }
    }