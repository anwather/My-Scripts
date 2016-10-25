workflow WF-Stop-AllVMs
{
    $connectionName = "AzureRunAsConnection"
        try
        {
            # Get the connection "AzureRunAsConnection "
            $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         

            "Logging in to Azure..."
            Add-AzureRmAccount `
                -ServicePrincipal `
                -TenantId $servicePrincipalConnection.TenantId `
                -ApplicationId $servicePrincipalConnection.ApplicationId `
                -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
        }
        catch {
            if (!$servicePrincipalConnection)
            {
                $ErrorMessage = "Connection $connectionName not found."
                throw $ErrorMessage
            } else{
                Write-Error -Message $_.Exception
                throw $_.Exception
            }
        }

        $obj = Get-AzureRmResourceGroup | Foreach {Get-AzureRMVM -ResourceGroupName $_.ResourceGroupName} | % {Get-AzureRMVM -ResourceGroupName $_.ResourceGroupName -Name $_.Name -Status} | Where {$_.Statuses[1].Code -notmatch "deallocated"} | Select ResourceGroupName,Name
        Write-Output $obj 

        Foreach -parallel ($o in $obj)
            {
                Stop-AzureRMVM -Name $o.Name -ResourceGroupName $o.ResourceGroupName -Force -Verbose
            }
}
