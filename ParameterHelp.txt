Function Demo-Help  {
 [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true,HelpMessage="Enter a string for computer name",Position=0)]
        [string]$ComputerName
    )
}