# Azure Container Registry — almacena las imágenes Docker
resource "azurerm_container_registry" "main" {
  name                = "${var.project}acr${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Basic"
  admin_enabled       = false   # AP-04: nunca admin credentials, usar managed identity
  tags                = var.tags
}
