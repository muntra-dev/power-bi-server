
# Delete resources
$Path = ".\variables.txt"
$parameters = Get-Content $Path | Out-String | ConvertFrom-StringData

Remove-AzResourceGroup -Name $parameters.ResourceGroupName -Force 


