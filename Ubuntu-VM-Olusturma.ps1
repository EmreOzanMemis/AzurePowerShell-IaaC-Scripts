# Parameters
$resourceGroup = "AzureRG"
$location = "westus"

# Create Resource Group
New-AzResourceGroup -Name $resourceGroup -Location $location

# Create Gateway Subnet Configuration
$gatewaySubnet = New-AzVirtualNetworkSubnetConfig -Name PSGatewaySubnet -AddressPrefix "10.172.100.0/27"

# Create Virtual Network and Subnets
$virtualNetwork = New-AzVirtualNetwork -Name PSAzureBCVnet -ResourceGroupName $resourceGroup -Location $location -AddressPrefix "10.172.100.0/24" -Subnet $gatewaySubnet
$virtualNetwork | Add-AzVirtualNetworkSubnetConfig -Name AzureFirewallSubnet -AddressPrefix "10.172.100.32/27" | Out-Null
$virtualNetwork | Add-AzVirtualNetworkSubnetConfig -Name AzureBastionSubnet -AddressPrefix "10.172.100.64/27" | Out-Null
$virtualNetwork | Add-AzVirtualNetworkSubnetConfig -Name PSDMZSubnet -AddressPrefix "10.172.100.96/27" | Out-Null
$virtualNetwork | Set-AzVirtualNetwork

# Create Public IP Address
$publicIp = New-AzPublicIpAddress -ResourceGroupName $resourceGroup -Name "VMIP" -Location $location -AllocationMethod Static -Sku Standard

# Create Credentials for the VM
$cred = Get-Credential -Message "Enter a username and password for the virtual machine."

# Create Virtual Machine
$vmName = "vm-docker"
New-AzVM -ResourceGroupName $resourceGroup -Name $vmName -Location $location `
    -Image "Canonical:0001-com-ubuntu-server-jammy:22_04-lts:latest" -Size "Standard_B4ms" `
    -VirtualNetworkName "PSAzureBCVnet" -SubnetName "PSDMZSubnet" -PublicIpAddressName $publicIp.Name `
    -Credential $cred -OpenPorts 22
