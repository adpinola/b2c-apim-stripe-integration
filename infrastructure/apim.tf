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

resource "azurerm_api_management_policy" "global" {
  api_management_id = azurerm_api_management.main.id
  xml_content       = file("./api-policy/global.xml")

  depends_on = [
    azurerm_api_management_named_value.apim_service_name,
    azurerm_api_management_named_value.app_service_name
  ]
}

data "azapi_resource_action" "master_subscription" {
  type                   = "Microsoft.ApiManagement/service/subscriptions@2023-05-01-preview"
  resource_id            = "${azurerm_api_management.main.id}/subscriptions/master"
  action                 = "listSecrets"
  response_export_values = ["*"]
}
