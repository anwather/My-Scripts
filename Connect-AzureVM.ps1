Function Connect-AzureVM
    {

    [CmdletBinding()]
    Param(
    $ResourceGroupName,
    $ComputerName
    )

    $ipAddress = Get-AzureRmPublicIpAddress -ResourceGroupName $resourceGroupName | Where Name -match $ComputerName | Select -ExpandProperty IpAddress
    
    $cmd = "mstsc /v:$ipaddress`:3389"

    Invoke-Expression $cmd

    }