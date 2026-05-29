# ─── Resource Group ────────────────────────────────────────────────────────────
resource "azurerm_resource_group" "main" {
  name     = "${var.project}-aks-rg-${var.environment}"
  location = var.location
  tags     = var.tags
}

# ─── Networking module ─────────────────────────────────────────────────────────
module "networking" {
  source = "./modules/networking"

  project              = var.project
  environment          = var.environment
  location             = var.location
  resource_group_name  = azurerm_resource_group.main.name
  vnet_cidr            = var.vnet_cidr
  aks_subnet_cidr      = var.aks_subnet_cidr
  services_subnet_cidr = var.services_subnet_cidr
  tags                 = var.tags
}

# ─── Supporting module (ACR, Key Vault) ────────────────────────────────────────
module "supporting" {
  source = "./modules/supporting"

  project             = var.project
  environment         = var.environment
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = var.tags
}

# ─── AKS module ────────────────────────────────────────────────────────────────
module "aks" {
  source = "./modules/aks"

  project             = var.project
  environment         = var.environment
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name

  kubernetes_version  = var.kubernetes_version
  aks_subnet_id       = module.networking.aks_subnet_id

  system_node_vm_size = var.system_node_vm_size
  user_node_vm_size   = var.user_node_vm_size
  user_node_min_count = var.user_node_min_count
  user_node_max_count = var.user_node_max_count

  tags = var.tags
}
