resource "azurerm_api_management" "main" {
  name                = module.naming.api_management.name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  publisher_name      = local.apim.publisher_name
  publisher_email     = local.apim.publisher_email

  sku_name = "Developer_1"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.apim.id]
  }

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

resource "azurerm_user_assigned_identity" "apim" {
  name                = module.naming.user_assigned_identity.name
  resource_group_name = azurerm_resource_group.rg.name
  location            = local.location
}

resource "azurerm_role_assignment" "apim_reader" {
  role_definition_name = "Reader"
  scope                = azurerm_resource_group.rg.id
  principal_id         = azurerm_user_assigned_identity.apim.principal_id
}
