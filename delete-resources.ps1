
# Delete resources
$Path = ".\server-config.txt"
$parameters = Get-Content $Path | Out-String | ConvertFrom-StringData

Remove-AzResourceGroup -Name $parameters.ResourceGroupName -Force
