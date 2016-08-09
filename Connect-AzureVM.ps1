Function Connect-AzureVM
    {

    [CmdletBinding()]
    Param(
    $ResourceGroupName,
    $ComputerName
    )

    $ipAddress = (Get-AzureRmPublicIpAddress -Name $computerName -ResourceGroupName $resourceGroupName).IpAddress
    
    $cmd = "mstsc /v:$ipaddress`:3389"

    Invoke-Expression $cmd

    }