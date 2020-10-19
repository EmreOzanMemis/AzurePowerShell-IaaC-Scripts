$publicipvm = New-AzPublicIpAddress -ResourceGroupName "AzureRG" -name "VMIP" -location "westus" -AllocationMethod Static -Sku Standard

$resourceGroup = "AzureRG" 
$location = "westus" 
$vmName = "PS-w2019-vm" 
$cred = Get-Credential -Message "Enter a username and password for the virtual machine." 
New-AzResourceGroup -Name $resourceGroup -Location $location
New-AzVM -ResourceGroupName $resourceGroup -Name $vmName -Location $location -ImageName "Win2019Datacenter" -Size "Standard_D2_v3" -VirtualNetworkName "PSAzureBCVnet" -SubnetName "PSDMZSubnet" -PublicIpAddressName $publicipvm -Credential $cred -OpenPorts 3389
