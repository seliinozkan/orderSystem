locals {
  order_image        = "${var.acr_server}/order-service:latest"
  notification_image = "${var.acr_server}/notification-service:latest"
}

resource "azurerm_container_app" "redis" {
  name                         = "${var.resource_prefix}-redis"
  container_app_environment_id = azurerm_container_app_environment.main.id
  resource_group_name          = azurerm_resource_group.main.name
  revision_mode                = "Single"

  ingress {
    external_enabled = false
    target_port      = 6379
    transport        = "tcp"

    traffic {
      latest_revision = true
      weight          = 100
    }
  }

  template {
    container {
      name   = "redis"
      image  = "redis:alpine"

      resources {
        cpu    = 0.5
        memory = "1Gi"
      }
    }
  }
}

resource "azurerm_container_app" "order_service" {
  name                         = "${var.resource_prefix}-order-service"
  container_app_environment_id = azurerm_container_app_environment.main.id
  resource_group_name          = azurerm_resource_group.main.name
  revision_mode                = "Single"

  identity {
    type = "SystemAssigned"
  }

  registry {
    server   = var.acr_server
    identity = "SystemAssigned"
  }

  dapr {
    app_id       = "${var.resource_prefix}-order-service"
    app_port     = 8080
    app_protocol = "http"
    enabled      = true
  }

  ingress {
    external_enabled = true
    target_port      = 8080

    traffic {
      latest_revision = true
      weight          = 100
    }
  }

  template {
    container {
      name   = "order-service"
      image  = local.order_image

      resources {
        cpu    = 0.5
        memory = "1Gi"
      }
    }
  }
}

resource "azurerm_container_app" "notification_service" {
  name                         = "${var.resource_prefix}-notification-service"
  container_app_environment_id = azurerm_container_app_environment.main.id
  resource_group_name          = azurerm_resource_group.main.name
  revision_mode                = "Single"

  identity {
    type = "SystemAssigned"
  }

  registry {
    server   = var.acr_server
    identity = "SystemAssigned"
  }

  dapr {
    app_id       = "${var.resource_prefix}-notification-service"
    app_port     = 8080
    app_protocol = "http"
    enabled      = true
  }

  ingress {
    external_enabled = false
    target_port      = 8080

    traffic {
      latest_revision = true
      weight          = 100
    }
  }

  template {
    container {
      name   = "notification-service"
      image  = local.notification_image

      resources {
        cpu    = 0.5
        memory = "1Gi"
      }
    }
  }
}
