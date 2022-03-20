## Create storage account and blob container
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

# Create container

$ContainerName = $parameters.ContainerName
New-AzStorageContainer -Name $ContainerName -Context $Context -Permission Blob

## Upload a file to the default account (inferred) access tier
$Script1 = ".\schedule-restore.ps1"

$Blob1 = @{
  File             = $Script1
  Container        = $ContainerName
  Blob             = "schedule-restore.ps1"
  Context          = $Context
  StandardBlobTier = 'Hot'
}
Set-AzStorageBlobContent @Blob1

## Upload a file to the default account (inferred) access tier
$Script2 = ".\task-schedule.ps1"

$Blob2 = @{
  File             = $Script2
  Container        = $ContainerName
  Blob             = "task-schedule.ps1"
  Context          = $Context
  StandardBlobTier = 'Hot'
}
Set-AzStorageBlobContent @Blob2
