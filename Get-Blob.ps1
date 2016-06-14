﻿Function Get-Blob
    {
    Param(
        [string]$ResourceGroupName,
        [string]$StorageAccountName,
        [string]$StorageContainerName,
        [string]$File,
        [string]$Destination
         )

    $context = Get-AzureRmStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName -Verbose

    $blob = Get-AzureStorageBlob -Container $StorageContainerName -Context $context -Verbose

    $blob | Get-AzureStorageBlobContent -Destination $Destination -Verbose
    }