# ─── AKS Cluster ───────────────────────────────────────────────────────────────
resource "azurerm_kubernetes_cluster" "main" {
  name                = "${var.project}-aks-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "${var.project}-aks-${var.environment}"
  kubernetes_version  = var.kubernetes_version

  # AP-04: managed identity en lugar de service principal con password
  identity {
    type = "SystemAssigned"
  }

  # ─── System node pool ────────────────────────────────────────────────────────
  # Solo corre pods de kube-system (CoreDNS, metrics-server, etc.)
  # AP-05: min 2 nodos para HA — el sistema no puede caer si un nodo se drena
  default_node_pool {
    name                = "system"
    node_count          = 2
    vm_size             = var.system_node_vm_size
    vnet_subnet_id      = var.aks_subnet_id
    os_disk_size_gb     = 50
    type                = "VirtualMachineScaleSets"

    # Solo corre workloads de sistema — las apps van al user pool
    only_critical_addons_enabled = true

    node_labels = {
      "nodepool-type" = "system"
      "environment"   = var.environment
    }
  }

  # ─── Networking ──────────────────────────────────────────────────────────────
  network_profile {
    network_plugin    = "azure"      # Azure CNI: cada pod tiene IP real de la VNet
    network_policy    = "azure"      # Habilita NetworkPolicy (AP-08)
    load_balancer_sku = "standard"
    outbound_type     = "loadBalancer"
  }

  # ─── Add-ons ─────────────────────────────────────────────────────────────────
  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  }

  azure_policy_enabled             = true   # Enforces Pod Security Admission
  http_application_routing_enabled = false  # Usaremos ingress-nginx en su lugar

  # ─── Auto-upgrade ────────────────────────────────────────────────────────────
  automatic_channel_upgrade = "patch"   # aplica patch versions automáticamente

  tags = var.tags
}

# ─── User node pool ────────────────────────────────────────────────────────────
# Corre las aplicaciones. Separado del system pool para que los workloads
# de usuario no puedan desplazar pods críticos de sistema (DNS, etc.)
resource "azurerm_kubernetes_cluster_node_pool" "user" {
  name                  = "user"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id
  vm_size               = var.user_node_vm_size
  vnet_subnet_id        = var.aks_subnet_id
  os_disk_size_gb       = 100

  # AP-07: autoscaler habilitado — no más réplicas fijas
  enable_auto_scaling = true
  min_count           = var.user_node_min_count
  max_count           = var.user_node_max_count

  node_labels = {
    "nodepool-type" = "user"
    "environment"   = var.environment
  }

  # Taint: solo pods que toleren este taint se schedulean aquí
  # (evita que pods de sistema acaben en el user pool)
  node_taints = ["workload=user:NoSchedule"]

  tags = var.tags
}

# ─── ACR → AKS pull permission ─────────────────────────────────────────────────
# Le da permiso al cluster para hacer pull de imágenes desde ACR
# sin guardar credenciales en ningún Secret de Kubernetes (AP-06)
resource "azurerm_role_assignment" "aks_acr_pull" {
  principal_id                     = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = var.acr_id
  skip_service_principal_aad_check = true
}

# ─── Log Analytics (observabilidad) ────────────────────────────────────────────
resource "azurerm_log_analytics_workspace" "main" {
  name                = "${var.project}-logs-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

terraform {
  required_version = ">= 1.7.0"
  required_providers {
    azurerm = { source = "hashicorp/azurerm" }
  }
}
