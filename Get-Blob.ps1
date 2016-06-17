Function Get-Blob
    {

    [CmdletBinding()]

    Param(
        [Parameter(Mandatory=$true)]
        [string]$ResourceGroupName,
        
        [Parameter(Mandatory=$true)]
        [string]$StorageAccountName,
        
        [Parameter(Mandatory=$true)]
        [ValidateScript({$_ -match "^[a-z\-]*$"})]
        [string]$StorageContainerName,
        
        [Parameter(ParameterSetName="Set1")]
        [string]$File,

        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path $_})]
        [string]$Destination,

        [Parameter(ParameterSetName="Set2")]
        [switch]$Grid
         )

    $context = (Get-AzureRmStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName -Verbose).Context

    if ($Grid)
        {
            $blob = Get-AzureStorageBlob -Container $StorageContainerName -Context $context | Out-GridView -PassThru
        }
    else
        {
            $blob = Get-AzureStorageBlob -Container $StorageContainerName -Context $context | Where Name -eq $File
        }
    
    $blob | Get-AzureStorageBlobContent -Destination $Destination -Verbose
    }