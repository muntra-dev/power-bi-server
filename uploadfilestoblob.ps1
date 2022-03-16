## create storage account and blob container
$Path = ".\variables.txt"
$parameters = Get-Content $Path | Out-String | ConvertFrom-StringData

$StorageHT = @{
  ResourceGroupName = $parameters.ResourceGroupName
  Name              = $parameters.StorageAccountName
  SkuName           = 'Standard_LRS'
  Location          =  $parameters.Location
}

$StorageAccount = New-AzStorageAccount @StorageHT
$Context = $StorageAccount.Context

# create container

$ContainerName = $parameters.ContainerName
New-AzStorageContainer -Name $ContainerName -Context $Context -Permission Blob

#
$configureScript = "$($pwd)/configure-server.ps1"

# upload a file to the default account (inferred) access tier
$Blob1 = @{
  File             = $configureScript
  Container        = $ContainerName
  Blob             = "configure-server.ps1"
  Context          = $Context
  StandardBlobTier = 'Hot'
}
Set-AzStorageBlobContent @Blob1

