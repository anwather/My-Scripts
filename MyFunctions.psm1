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

Function Stop-AzureVMs
    {
    Param($ResourceGroupName)

#$resourceGroupName = Read-Host "Enter the resource group name"
    $vmsAll = Get-AzureRMVM -ResourceGroupName $resourceGroupName
    $obj = @()

    Class RunningVM
        {

        [string]$Name

        RunningVM([string]$Name)
            {
            $this.Name = $Name
            }

        }

    foreach ($vm in $vmsAll)
        {

        $vmRunning = (Get-AzureRMVM -ResourceGroupName $resourceGroupName -Name $vm.OSProfile.ComputerName -Status).Statuses | Where Code -Match "Running"

        if ($null -ne $vmRunning)
            {
            $obj += [RunningVM]::new($vm.OSProfile.ComputerName)
            }
        }

    foreach ($vm in $obj)
        {
        Stop-AzureRMVM -Name $vm.Name -ResourceGroupName $resourceGroupName -Force -Verbose
        }
    }

Export-ModuleMember *