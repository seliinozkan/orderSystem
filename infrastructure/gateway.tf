resource "azurerm_api_management" "gateway" {
  name                = "${var.resource_prefix}-gateway"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  publisher_name      = "selin"
  publisher_email     = "ops@selin.example.com"
  sku_name            = "Consumption_0"
}

resource "azurerm_api_management_api" "orders" {
  name                = "${var.resource_prefix}-orders-api"
  resource_group_name = azurerm_resource_group.main.name
  api_management_name = azurerm_api_management.gateway.name
  revision            = "1"
  display_name        = "Orders API"
  path                = "orders"
  protocols           = ["https"]
  service_url         = "https://${azurerm_container_app.order_service.ingress[0].fqdn}"
}

resource "azurerm_api_management_api_operation" "create_order" {
  operation_id        = "create-order"
  resource_group_name = azurerm_resource_group.main.name
  api_management_name = azurerm_api_management.gateway.name
  api_name            = azurerm_api_management_api.orders.name
  display_name        = "Create Order"
  method              = "POST"
  url_template        = "/"

  response {
    status_code = 200
  }
}
