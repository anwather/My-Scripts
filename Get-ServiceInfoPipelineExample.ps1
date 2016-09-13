Function Get-ServiceInfo
    {

    [CmdletBinding()]
    Param(

    [Parameter(Mandatory=$true)]
    [string]$Name,

    [Parameter(ValueFromPipeline=$true)]
    [string[]]$ComputerName="localhost"
    )

    Process 
        {
            Write-Verbose "Checking service: $Name on computer: $_"
            Get-Service -Name $Name -ComputerName $_
        }
    
    }