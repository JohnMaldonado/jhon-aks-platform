project     = "jhon"
environment = "dev"
location    = "eastus"

# Networking
vnet_cidr            = "10.0.0.0/8"
aks_subnet_cidr      = "10.240.0.0/16"
services_subnet_cidr = "10.241.0.0/16"

# AKS
kubernetes_version  = "1.33.11"
system_node_vm_size = "Standard_D2s_v3"
user_node_vm_size   = "Standard_D2s_v3"   # más pequeño en dev
user_node_min_count = 1
user_node_max_count = 3

tags = {
  environment = "dev"
  project     = "jhon-aks-platform"
  managed_by  = "terraform"
}
