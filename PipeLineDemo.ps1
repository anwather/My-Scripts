Function PipeLineDemo
{
    [CmdletBinding()]
    Param(
    [Parameter(ValueFromPipeline=$true)]
    [string[]]$Input1
    )

    Process {
    Write-Output $Input1
    }

}