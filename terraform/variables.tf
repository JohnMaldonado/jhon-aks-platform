# ─── Project ───────────────────────────────────────────────────────────────────
variable "project" {
  description = "Project name prefix. Used in all resource names."
  type        = string
  default     = "jhon"
}

variable "environment" {
  description = "Deployment environment: dev | staging | prod"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be dev, staging, or prod."
  }
}

# ─── Azure ─────────────────────────────────────────────────────────────────────
variable "location" {
  description = "Azure region for all resources."
  type        = string
  default     = "eastus"
}

# ─── Networking ────────────────────────────────────────────────────────────────
variable "vnet_cidr" {
  description = "CIDR block for the Virtual Network."
  type        = string
  default     = "10.0.0.0/8"
}

variable "aks_subnet_cidr" {
  description = "CIDR for AKS node subnet. Must be within vnet_cidr."
  type        = string
  default     = "10.240.0.0/16"
}

variable "services_subnet_cidr" {
  description = "CIDR for internal services (postgres, etc)."
  type        = string
  default     = "10.241.0.0/16"
}

# ─── AKS ───────────────────────────────────────────────────────────────────────
variable "kubernetes_version" {
  description = "Kubernetes version for the AKS cluster."
  type        = string
  default     = "1.29"
}

variable "system_node_vm_size" {
  description = "VM size for system node pool (runs kube-system pods)."
  type        = string
  default     = "Standard_D2s_v3"
}

variable "user_node_vm_size" {
  description = "VM size for user node pool (runs application pods)."
  type        = string
  default     = "Standard_D4s_v3"
}

variable "user_node_min_count" {
  description = "Minimum nodes in user pool (autoscaler lower bound)."
  type        = number
  default     = 2
}

variable "user_node_max_count" {
  description = "Maximum nodes in user pool (autoscaler upper bound)."
  type        = number
  default     = 5
}

# ─── Tags ──────────────────────────────────────────────────────────────────────
variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}
