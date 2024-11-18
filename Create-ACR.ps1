# Değişkenleri tanımlayın
$resourceGroupName = "AzureRG-ACR"
$location = "westus"
$acrName = "emreozan"
$sku = "Standard"

# Kaynak grubunu oluşturun
New-AzResourceGroup -Name $resourceGroupName -Location $location

# Azure Container Registry'yi oluşturun
New-AzContainerRegistry -ResourceGroupName $resourceGroupName -Name $acrName -Sku $sku
