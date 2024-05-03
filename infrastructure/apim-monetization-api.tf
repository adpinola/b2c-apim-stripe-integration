resource "azurerm_api_management_backend" "monetization" {
  name                = "ContainerApp_${azurerm_container_app.monetization_server.name}"
  description         = azurerm_container_app.monetization_server.name
  api_management_name = azurerm_api_management.main.name
  resource_group_name = azurerm_resource_group.rg.name
  protocol            = "http"
  url                 = "https://${azurerm_container_app.monetization_server.ingress.0.fqdn}"
}

resource "azurerm_api_management_api" "monetization" {
  name                = azurerm_container_app.monetization_server.name
  api_management_name = azurerm_api_management.main.name
  resource_group_name = azurerm_resource_group.rg.name
  revision            = "1"

  service_url  = azurerm_api_management_backend.monetization.url
  display_name = azurerm_container_app.monetization_server.name
  protocols    = ["https"]
  path         = "monetize"

  import {
    content_format = "openapi"
    content_value  = file("./api-definition/capp.yaml")
  }
}

resource "azurerm_api_management_api_policy" "monetization" {
  api_name            = azurerm_api_management_api.monetization.name
  api_management_name = azurerm_api_management.main.name
  resource_group_name = azurerm_resource_group.rg.name

  xml_content = file("./api-policy/capp.xml")
}