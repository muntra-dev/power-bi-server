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
Start-Sleep -s 5

$Context = $StorageAccount.Context

# create container

$ContainerName = $parameters.ContainerName
New-AzStorageContainer -Name $ContainerName -Context $Context -Permission Blob

## upload a file to the default account (inferred) access tier
$configureScript = ".\configure-server.ps1"

$Blob1 = @{
  File             = $configureScript
  Container        = $ContainerName
  Blob             = "configure-server.ps1"
  Context          = $Context
  StandardBlobTier = 'Hot'
}
Set-AzStorageBlobContent @Blob1

## upload a file to the default account (inferred) access tier
$databaseScript = ".\restore-databases.ps1"

$Blob2 = @{
  File             = $databaseScript
  Container        = $ContainerName
  Blob             = "restore-databases.ps1"
  Context          = $Context
  StandardBlobTier = 'Hot'
}
Set-AzStorageBlobContent @Blob2


