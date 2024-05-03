resource "azurerm_api_management" "main" {
  name                = module.naming.api_management.name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  publisher_name      = local.apim.publisher_name
  publisher_email     = local.apim.publisher_email

  sku_name = "Developer_1"

  protocols {
    enable_http2 = true
  }

  tags = local.tags
}
