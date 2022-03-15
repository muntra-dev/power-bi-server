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

$rule1 = New-AzNetworkSecurityRuleConfig -Name rdp-rule -Description "Allow RDP" `
    -Access Allow -Protocol Tcp -Direction Inbound -Priority 100 -SourceAddressPrefix `
    Internet -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 3389
$nsg = New-AzNetworkSecurityGroup -ResourceGroupName $parameters.ResourceGroupName -Location $parameters.Location -Name `
    $nsgName -SecurityRules $rule1

$SingleSubnet = New-AzVirtualNetworkSubnetConfig -Name $parameters.SubnetName -AddressPrefix $SubnetAddressPrefix -NetworkSecurityGroup $nsg
$Vnet = New-AzVirtualNetwork -Name $vnet -ResourceGroupName $parameters.ResourceGroupName -Location $parameters.Location -AddressPrefix $VnetAddressPrefix -Subnet $SingleSubnet
$PIP = New-AzPublicIpAddress -Name $publicIP -DomainNameLabel $parameters.DNSNameLabel -ResourceGroupName $parameters.ResourceGroupName -Location $parameters.Location -AllocationMethod Dynamic
$NIC = New-AzNetworkInterface -Name $NIC -ResourceGroupName $parameters.ResourceGroupName -Location $parameters.Location -SubnetId $Vnet.Subnets[0].Id -PublicIpAddressId $PIP.Id

$Credential = New-Object System.Management.Automation.PSCredential ($AdminUser, $AdminSecurePassword);

$VirtualMachine = New-AzVMConfig -VMName $parameters.ServerName -VMSize $parameters.VMSize
$VirtualMachine = Set-AzVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $parameters.ServerName -Credential $Credential -ProvisionVMAgent -EnableAutoUpdate
$VirtualMachine = Add-AzVMNetworkInterface -VM $VirtualMachine -Id $NIC.Id
$VirtualMachine = Set-AzVMSourceImage -VM $VirtualMachine -PublisherName 'MicrosoftWindowsServer' -Offer 'WindowsServer' -Skus '2019-datacenter-gensecond' -Version latest

New-AzVM -ResourceGroupName $parameters.ResourceGroupName -Location $parameters.Location -VM $VirtualMachine -Verbose 

