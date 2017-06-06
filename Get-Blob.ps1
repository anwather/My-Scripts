<#
.Synopsis
   Gets blob content from Azure
.DESCRIPTION
   Use the Get-Blob function to connect to a storage account and download a blob to a local location. If the name of the blob is unknown then use the Grid
   switch to display a grid view where a file can be chosen.
.EXAMPLE
   Get-Blob -ResourceGroupName test -StorageAccountName mystorage -StorageContainerName vhds -File DC01.vhd -Destination C:\Temp
.EXAMPLE
   Get-Blob -ResourceGroupName test -StorageAccountName mystorage -StorageContainerName vhds -Destination C:\Temp -Grid
#>

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
            $blob = Get-AzureStorageBlob -Container $StorageContainerName -Context $context | Where-Object Name -eq $File
        }
    
    $blob | Get-AzureStorageBlobContent -Destination $Destination -Verbose
    }