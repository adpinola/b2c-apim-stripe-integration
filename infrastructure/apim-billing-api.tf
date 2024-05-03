locals {
  serviceUrl       = ""
  artifactsBaseUrl = ""
}

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
    content_value  = file("./infrastructure/api-definition/billing.yaml")
  }
}

resource "azurerm_api_management_api_operation" "get_monetization_models" {
  operation_id        = "get_monetization_models"
  method              = "GET"
  url_template        = "/get_monetization_models"
  display_name        = "Get Monetization Models"
  resource_group_name = azurerm_api_management_api.billing_api.resource_group_name
  api_name            = azurerm_api_management_api.billing_api.name
  api_management_name = azurerm_api_management_api.billing_api.api_management_name
}

resource "azurerm_api_management_api_operation" "get_products" {
  operation_id        = "get_products"
  method              = "GET"
  url_template        = "/get_products"
  display_name        = "Get Products"
  resource_group_name = azurerm_api_management_api.billing_api.resource_group_name
  api_name            = azurerm_api_management_api.billing_api.name
  api_management_name = azurerm_api_management_api.billing_api.api_management_name
}

resource "azurerm_api_management_api_operation_policy" "get_monetization_models_policy" {
  api_name            = azurerm_api_management_api.billing_api.name
  api_management_name = azurerm_api_management_api.billing_api.api_management_name
  resource_group_name = azurerm_api_management_api.billing_api.resource_group_name
  operation_id        = azurerm_api_management_api_operation.get_monetization_models.name

  xml_content = file("./infrastructure/api-policy/billing-get_monetization_models.xml")
}

resource "azurerm_api_management_api_operation_policy" "get_products_policy" {
  api_name            = azurerm_api_management_api.billing_api.name
  api_management_name = azurerm_api_management_api.billing_api.api_management_name
  resource_group_name = azurerm_api_management_api.billing_api.resource_group_name
  operation_id        = azurerm_api_management_api_operation.get_products.name

  xml_content = file("./infrastructure/api-policy/billing-get_products.xml")
}
