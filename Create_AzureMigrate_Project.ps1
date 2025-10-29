# === Hızlı Azure Migrate Proje Oluşturucu (Cloud Shell / Azure PowerShell) ===
# Değiştirmeniz gerekenler:
$SubscriptionId = "00000000-0000-0000-0000-000000000000"
$ResourceGroup  = "rg-migrate-demo"
$ProjectName    = "amg-demo"
$Location       = "westeurope"   # ör: westeurope, northeurope, germanywestcentral
$Tags           = @{ Owner="Emre"; Environment="PoC" }  # opsiyonel

# --- Abonelik bağlamı ---
Set-AzContext -Subscription $SubscriptionId | Out-Null

# --- Provider kaydı (gerekirse) ---
$prov = Get-AzResourceProvider -ProviderNamespace "Microsoft.Migrate"
if ($prov.RegistrationState -ne "Registered") {
  Register-AzResourceProvider -ProviderNamespace "Microsoft.Migrate" | Out-Null
  do {
    Start-Sleep 2
    $prov = Get-AzResourceProvider -ProviderNamespace "Microsoft.Migrate"
  } while ($prov.RegistrationState -ne "Registered")
}

# --- Resource Group (yoksa oluştur) ---
$rg = Get-AzResourceGroup -Name $ResourceGroup -ErrorAction SilentlyContinue
if (-not $rg) {
  $rg = New-AzResourceGroup -Name $ResourceGroup -Location $Location
}

# --- Proje (yoksa oluştur; varsa etiketleri birleştir)---
$project = Get-AzMigrateProject -ResourceGroupName $ResourceGroup -ErrorAction SilentlyContinue |
           Where-Object { $_.Name -eq $ProjectName }

if ($project) {
  if ($Tags.Count -gt 0) {
    $merged = @{}
    if ($project.Tags) { $project.Tags.GetEnumerator() | % { $merged[$_.Key]=$_.Value } }
    $Tags.GetEnumerator() | % { $merged[$_.Key]=$_.Value }
    Set-AzResource -ResourceId $project.Id -Tag $merged -Force | Out-Null
    $project = Get-AzMigrateProject -ResourceGroupName $ResourceGroup | Where-Object Name -eq $ProjectName
  }
} else {
  $project = New-AzMigrateProject -Name $ProjectName -ResourceGroupName $ResourceGroup -Location $Location -Tag $Tags
}

# --- Kısa çıktı ---
[PSCustomObject]@{
  SubscriptionId = $SubscriptionId
  ResourceGroup  = $ResourceGroup
  ProjectName    = $ProjectName
  Location       = $Location
  ProjectId      = $project.Id
  PortalLink     = "https://portal.azure.com/#@/resource$($project.Id)"
}
