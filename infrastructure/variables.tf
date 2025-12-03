variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "eastus"
}

variable "resource_prefix" {
  description = "Prefix for all resource names (must start with selin)"
  type        = string
  default     = "selin"

  validation {
    condition     = can(regex("^selin", var.resource_prefix))
    error_message = "The resource prefix must start with 'selin'."
  }
}

variable "acr_server" {
  description = "Azure Container Registry login server"
  type        = string
  default     = "selinacr23.azurecr.io"
}
