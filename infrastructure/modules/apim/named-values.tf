locals {
  named_values = merge(var.named_values, {
    UaiClientId       = azurerm_user_assigned_identity.apim.client_id
    ApimServiceName   = azurerm_api_management.main.name
    ResourceGroupName = var.resource_group_name
    SubscriptionId    = data.azurerm_client_config.current.subscription_id
  })
}

resource "azurerm_api_management_named_value" "named_values" {
  for_each = local.named_values

  name                = format("%s%s", lower(substr(each.key, 0, 1)), substr(each.key, 1, length(each.key)))
  display_name        = each.key
  api_management_name = azurerm_api_management.main.name
  resource_group_name = var.resource_group_name
  value               = each.value
}
