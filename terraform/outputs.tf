output "resource_group_name" {
  description = "Name of the main resource group."
  value       = azurerm_resource_group.main.name
}

output "aks_cluster_name" {
  description = "Name of the AKS cluster."
  value       = module.aks.cluster_name
}

output "acr_login_server" {
  description = "Container registry login server URL."
  value       = module.supporting.acr_login_server
}

output "kubeconfig_command" {
  description = "Command to configure kubectl for this cluster."
  value       = "az aks get-credentials --resource-group ${azurerm_resource_group.main.name} --name ${module.aks.cluster_name}"
}
