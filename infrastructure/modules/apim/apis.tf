locals {
  filtered_apis_policy = {
    for api_id, api_config in var.apis :
    api_id => api_config
    if api_config.policy_definition != null
  }

  filtered_apis_backend = {
    for api_id, api_config in var.apis :
    api_id => api_config
    if length(compact([api_config.backend_protocol, api_config.backend_url])) > 0
  }
}

resource "azurerm_api_management_backend" "backends" {
  for_each = local.filtered_apis_backend

  name                = each.key
  description         = each.value.description
  api_management_name = azurerm_api_management.main.name
  resource_group_name = var.resource_group_name
  protocol            = each.value.backend_protocol
  url                 = each.value.backend_url
}

resource "azurerm_api_management_api" "apis" {
  for_each = var.apis

  name                = each.key
  api_management_name = azurerm_api_management.main.name
  resource_group_name = var.resource_group_name
  revision            = "1"

  service_url           = length(keys(lookup(azurerm_api_management_backend.backends, each.key, {}))) > 0 ? azurerm_api_management_backend.backends[each.key].url : "https://management.azure.com"
  display_name          = each.key
  protocols             = each.value.api_protocols
  path                  = each.value.api_path
  subscription_required = each.value.subscription_required

  import {
    content_format = "openapi"
    content_value  = each.value.api_definition
  }
}

resource "azurerm_api_management_api_policy" "policies" {
  for_each = local.filtered_apis_policy

  api_name            = each.key
  api_management_name = azurerm_api_management.main.name
  resource_group_name = var.resource_group_name

  xml_content = each.value.policy_definition

  depends_on = [
    azurerm_api_management_api.apis,
    azurerm_api_management_named_value.named_values
  ]
}
