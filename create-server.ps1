# create RG
$Path = ".\variables.txt"
$parameters = Get-Content $Path | Out-String | ConvertFrom-StringData

New-AzResourceGroup -Name $parameters.ResourceGroupName -Location $parameters.Location -Force

# create server and open RDP port

$AdminUser = $parameters.AdminUser 
$AdminSecurePassword = ConvertTo-SecureString $parameters.Password -AsPlainText -Force
$SubnetAddressPrefix = "10.0.0.0/24"
$VnetAddressPrefix = "10.0.0.0/16"
$NIC = "$($parameters.ServerName)-nic"
$Vnet = "$($parameters.Location)-$($parameters.VnetName)"
$nsgName = "$($parameters.Servername)-$($parameters.NSGName)" 
$publicIP = "$($parameters.Servername)-$($parameters.PublicIP)"

$rule1 = New-AzNetworkSecurityRuleConfig -Name storage-service-rule -Description "Allow Azure Storage" `
    -Access Allow -Protocol * -Direction Outbound -Priority 110 -SourceAddressPrefix `
    VirtualNetwork -SourcePortRange * -DestinationAddressPrefix Storage -DestinationPortRange 445

$rule2 = New-AzNetworkSecurityRuleConfig -Name rdp-rule -Description "Allow RDP" `
    -Access Allow -Protocol Tcp -Direction Inbound -Priority 100 -SourceAddressPrefix `
    Internet -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 3389

$nsg = New-AzNetworkSecurityGroup -ResourceGroupName $parameters.ResourceGroupName -Location $parameters.Location -Name `
    $nsgName -SecurityRules $rule1,$rule2

$SingleSubnet = New-AzVirtualNetworkSubnetConfig -Name $parameters.SubnetName -AddressPrefix $SubnetAddressPrefix -NetworkSecurityGroup $nsg -ServiceEndpoint "Microsoft.Storage"
$Vnet = New-AzVirtualNetwork -Name $vnet -ResourceGroupName $parameters.ResourceGroupName -Location $parameters.Location -AddressPrefix $VnetAddressPrefix -Subnet $SingleSubnet
$PIP = New-AzPublicIpAddress -Name $publicIP -DomainNameLabel $parameters.DNSNameLabel -ResourceGroupName $parameters.ResourceGroupName -Location $parameters.Location -AllocationMethod Dynamic
$NIC = New-AzNetworkInterface -Name $NIC -ResourceGroupName $parameters.ResourceGroupName -Location $parameters.Location -SubnetId $Vnet.Subnets[0].Id -PublicIpAddressId $PIP.Id

$Credential = New-Object System.Management.Automation.PSCredential ($AdminUser, $AdminSecurePassword);

$VirtualMachine = New-AzVMConfig -VMName $parameters.ServerName -VMSize $parameters.VMSize
$VirtualMachine = Set-AzVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $parameters.ServerName -Credential $Credential -ProvisionVMAgent -EnableAutoUpdate
$VirtualMachine = Add-AzVMNetworkInterface -VM $VirtualMachine -Id $NIC.Id
$VirtualMachine = Set-AzVMSourceImage -VM $VirtualMachine -PublisherName 'MicrosoftWindowsServer' -Offer 'WindowsServer' -Skus '2019-datacenter-gensecond' -Version latest

New-AzVM -ResourceGroupName $parameters.ResourceGroupName -Location $parameters.Location -VM $VirtualMachine -Verbose 

# upload content to blob container

& .\uploadfilestoblob.ps1

Start-Sleep -s 5
### Run script to install mysql, powerbi

# define your file URI
$uri1 = "https://$($parameters.StorageAccountName).blob.core.windows.net/$($parameters.ContainerName)/configure-server.ps1"
$uri2 = "https://$($parameters.StorageAccountName).blob.core.windows.net/$($parameters.ContainerName)/restore-databases.ps1"

$fileUri = @($uri1, $uri2)

$settings = @{"fileUris" = $fileUri};

$storageAcctName = $parameters.StorageAccountName
$key = (Get-AzStorageAccountKey -ResourceGroupName $parameters.ResourceGroupName -AccountName $parameters.storageAccountName) | Where-Object {$_.KeyName -eq "key1"}
$storageKey = $key.Value
$protectedSettings = @{"storageAccountName" = $storageAcctName; "storageAccountKey" = $storageKey; "commandToExecute" = 'powershell -ExecutionPolicy Unrestricted -File "configure-server.ps1"'};

Write-Host "Start configuring server "

Set-AzVMExtension -ResourceGroupName $parameters.ResourceGroupName `
    -Location $parameters.Location `
    -VMName $parameters.ServerName `
    -Name "SereverConfiguration" `
    -Publisher "Microsoft.Compute" `
    -ExtensionType "CustomScriptExtension" `
    -TypeHandlerVersion "1.10" `
    -Settings $settings `
    -ProtectedSettings $protectedSettings;


Write-Host "Server Configuration has completed successfully" -ForegroundColor green 

# reboot required for the packages we installed
#Restart-AzVM -ResourceGroupName  $parameters.ResourceGroupName -Name $parameters.ServerName

