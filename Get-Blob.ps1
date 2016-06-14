Function Get-Blob
    {
    Param($ResourceGroupName,$StorageAccountName,$StorageContainerName,$File,$Destination)

    $context = Get-AzureRmStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName -Verbose

    $blob = Get-AzureStorageBlob -Container $StorageContainerName -Context $context -Verbose

    $blob | Get-AzureStorageBlobContent -Destination $Destination -Verbose
    }