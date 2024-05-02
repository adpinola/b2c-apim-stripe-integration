resource "azurerm_api_management_api_operation_policy" "policy" {
  for_each = var.operation_policies

  operation_id        = each.key
  api_name            = each.value.api_name
  api_management_name = azurerm_api_management.main.name
  resource_group_name = var.resource_group_name

  xml_content = each.value.policy_definition

  depends_on = [
    azurerm_api_management_named_value.named_values,
    azurerm_api_management_api.apis
  ]
}
