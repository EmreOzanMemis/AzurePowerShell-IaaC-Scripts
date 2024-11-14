$resourceGroup = "AzureRG"
$location = "westus"
$gatewaysubnet = New-AzVirtualNetworkSubnetConfig -Name PSGatewaySubnet -AddressPrefix "10.172.100.0/27"
$virtualNetwork = New-AzVirtualNetwork -Name PSAzureBCVnet -ResourceGroupName AzureRG -Location westus -AddressPrefix "10.172.100.0/24" -Subnet $gatewaysubnet
Add-AzVirtualNetworkSubnetConfig -Name AzureFirewallSubnet -VirtualNetwork $virtualNetwork -AddressPrefix "10.172.100.32/27"
Add-AzVirtualNetworkSubnetConfig -Name AzureBastionSubnet -VirtualNetwork $virtualNetwork -AddressPrefix "10.172.100.64/27"
Add-AzVirtualNetworkSubnetConfig -Name PSDMZSubnet -VirtualNetwork $virtualNetwork -AddressPrefix "10.172.100.96/27"
$virtualNetwork | Set-AzVirtualNetwork
$publicipvm = New-AzPublicIpAddress -ResourceGroupName "AzureRG" -name "VMIP" -location "westus" -AllocationMethod Static -Sku Standard
$vmName = "vm-docker"
$cred = Get-Credential -Message "Enter a username and password for the virtual machine."
New-AzResourceGroup -Name $resourceGroup -Location $location
New-AzVM -ResourceGroupName $resourceGroup -Name $vmName -Location $location -Image "Canonical:0001-com-ubuntu-server-jammy:22_04-lts:latest" -Size "Standard_B4ms" -VirtualNetworkName "PSAzureBCVnet" -SubnetName "PSDMZSubnet" -PublicIpAddressName $publicipvm -Credential $cred -OpenPorts 22
