# Create resource group
$Path = ".\server-config.txt"
$parameters = Get-Content $Path | Out-String | ConvertFrom-StringData

New-AzResourceGroup -Name $parameters.ResourceGroupName -Location $parameters.Location -Force

# Create server and open RDP port

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
$VirtualMachine = Set-AzVMSourceImage -VM $VirtualMachine -PublisherName 'MicrosoftWindowsServer' -Offer 'WindowsServer' -Skus '2019-datacenter' -Version latest

New-AzVM -ResourceGroupName $parameters.ResourceGroupName -Location $parameters.Location -VM $VirtualMachine -Verbose

Start-Sleep -s 30

Write-Host "Start configuring server "

# Run installations file

Write-Host "Installing Power BI and Mysql 5.7.36 server "
Invoke-AzVMRunCommand -ResourceGroupName $parameters.ResourceGroupName -VMName $parameters.ServerName -CommandId 'RunPowerShellScript' -ScriptPath '.\installations.ps1'
# Perform required reboot, for the packages just installed

Write-Host "Reboot VM: Required by the Installations we did" -ForegroundColor green

Restart-AzVM -ResourceGroupName  $parameters.ResourceGroupName -Name $parameters.ServerName

Start-Sleep -s 30
# initial databases restore

Write-Host "Restoring Databases from AWS "
Invoke-AzVMRunCommand -ResourceGroupName $parameters.ResourceGroupName -VMName $parameters.ServerName -CommandId 'RunPowerShellScript' -ScriptPath 'restore-databases.ps1'

# Upload content to blob container

& .\upload-files-to-blob.ps1

# Define file URIs
$uri1 = "https://$($parameters.StorageAccountName).blob.core.windows.net/$($parameters.ContainerName)/task-schedule.ps1"
$uri2 = "https://$($parameters.StorageAccountName).blob.core.windows.net/$($parameters.ContainerName)/schedule-restore.ps1"

$fileUri = @($uri1, $uri2)

$settings = @{"fileUris" = $fileUri};

$storageAcctName = $parameters.StorageAccountName
$key = (Get-AzStorageAccountKey -ResourceGroupName $parameters.ResourceGroupName -AccountName $parameters.storageAccountName) | Where-Object {$_.KeyName -eq "key1"}
$storageKey = $key.Value
$protectedSettings = @{"storageAccountName" = $storageAcctName; "storageAccountKey" = $storageKey; "commandToExecute" = 'powershell -ExecutionPolicy Unrestricted -File "task-schedule.ps1"'};

Write-Host "Scheduling task for daily databases restore script "

Set-AzVMExtension -ResourceGroupName $parameters.ResourceGroupName `
    -Location $parameters.Location `
    -VMName $parameters.ServerName `
    -Name "SereverConfiguration" `
    -Publisher "Microsoft.Compute" `
    -ExtensionType "CustomScriptExtension" `
    -TypeHandlerVersion "1.10" `
    -Settings $settings `
    -ProtectedSettings $protectedSettings;

Write-Host "Server configuration has completed successfully" -ForegroundColor green

Write-Host "Reboot done: You can now log in to your VM" -ForegroundColor green

Write-Host "RDP using below DNS or IP" -ForegroundColor green

Write-Host "Public DNS: " $parameters.DNSNameLabel
Write-Host "Public IP: "  (Get-AzPublicIpAddress -Name $publicIP).IpAddress
