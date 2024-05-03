resource "azurerm_api_management_api" "billing_api" {
  name                = "billing"
  resource_group_name = azurerm_api_management.main.resource_group_name
  api_management_name = azurerm_api_management.main.name

  revision = "1"

  path                  = "billing"
  display_name          = "billing"
  protocols             = ["https"]
  subscription_required = true
  service_url           = "https://api.microsoft.com/billing"

  import {
    content_format = "openapi"
    content_value  = file("./api-definition/billing.yaml")
  }
}

resource "azurerm_api_management_api_operation_policy" "get_monetization_models_policy" {
  api_name            = azurerm_api_management_api.billing_api.name
  api_management_name = azurerm_api_management_api.billing_api.api_management_name
  resource_group_name = azurerm_api_management_api.billing_api.resource_group_name
  operation_id        = "get_monetization_models"

  xml_content = file("./api-policy/billing-get_monetization_models.xml")

  depends_on = [azurerm_api_management_named_value.monetization_models]
}

resource "azurerm_api_management_api_operation_policy" "get_products_policy" {
  api_name            = azurerm_api_management_api.billing_api.name
  api_management_name = azurerm_api_management_api.billing_api.api_management_name
  resource_group_name = azurerm_api_management_api.billing_api.resource_group_name
  operation_id        = "get_products"

  xml_content = file("./api-policy/billing-get_products.xml")

  depends_on = [
    azurerm_api_management_named_value.apim_service_name,
    azurerm_api_management_named_value.subscription_id,
    azurerm_api_management_named_value.resource_group_name
  ]
}
