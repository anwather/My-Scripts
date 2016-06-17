Function Get-Blob
    {

    [CmdletBinding()]

    Param(
        [string]$ResourceGroupName,
        [string]$StorageAccountName,
        
        [ValidateScript({$_ -match "^[a-z\-]*$"})]
        [string]$StorageContainerName,
        [string]$File,

        [ValidateScript({Test-Path $_})]
        [string]$Destination
         )

    $context = (Get-AzureRmStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName -Verbose).Context

    $blob = Get-AzureStorageBlob -Container $StorageContainerName -Context $context | Where Name -eq $File

    $blob | Get-AzureStorageBlobContent -Destination $Destination -Verbose
    }