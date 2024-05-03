resource "azurerm_api_management_named_value" "subscription_id" {
  name                = "subscriptionId"
  display_name        = "SubscriptionId"
  api_management_name = azurerm_api_management.main.name
  resource_group_name = azurerm_resource_group.rg.name
  value               = data.azurerm_client_config.current.subscription_id
}

resource "azurerm_api_management_named_value" "resource_group_name" {
  name                = "resourceGroupName"
  display_name        = "SubscriptionId"
  api_management_name = azurerm_api_management.main.name
  resource_group_name = azurerm_resource_group.rg.name
  value               = azurerm_resource_group.rg.name
}

resource "azurerm_api_management_named_value" "apim_service_name" {
  name                = "apimServiceName"
  display_name        = "SubscriptionId"
  api_management_name = azurerm_api_management.main.name
  resource_group_name = azurerm_resource_group.rg.name
  value               = azurerm_api_management.main.name
}

resource "azurerm_api_management_named_value" "app_service_name" {
  name                = "appServiceName"
  display_name        = "SubscriptionId"
  api_management_name = azurerm_api_management.main.name
  resource_group_name = azurerm_resource_group.rg.name
  value               = azurerm_container_app.monetization_server.name
}

resource "azurerm_api_management_named_value" "monetization_models_url" {
  name                = "monetizationModelsUrl"
  display_name        = "SubscriptionId"
  api_management_name = azurerm_api_management.main.name
  resource_group_name = azurerm_resource_group.rg.name
  value               = file("../payment/monetizationModels.json")
}
