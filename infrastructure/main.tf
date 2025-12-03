locals {
  prefix = var.resource_prefix
}

resource "azurerm_resource_group" "main" {
  name     = "${local.prefix}-resources"
  location = var.location
}

resource "azurerm_log_analytics_workspace" "main" {
  name                = "${local.prefix}-logs"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_container_app_environment" "main" {
  name                       = "${local.prefix}-apps-env"
  location                   = azurerm_resource_group.main.location
  resource_group_name        = azurerm_resource_group.main.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
}

resource "azurerm_container_app_environment_dapr_component" "redis_pubsub" {
  name                         = "pubsub.redis"
  container_app_environment_id = azurerm_container_app_environment.main.id
  component_type               = "redis"
  version                      = "v1"

  metadata {
    name  = "redisHost"
    value = "${local.prefix}-redis"
  }

  metadata {
    name  = "redisPort"
    value = "6379"
  }

  metadata {
    name  = "enableTLS"
    value = "false"
  }

  scopes = [
    "${local.prefix}-order-service",
    "${local.prefix}-notification-service"
  ]
}
