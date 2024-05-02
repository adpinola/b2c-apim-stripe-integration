data "azurerm_resource_group" "target_rg" {
  name = var.resource_group_name
}

resource "azurerm_role_assignment" "uai_role_assignment" {
  for_each = toset(var.roles)

  role_definition_name = each.key
  scope                = data.azurerm_resource_group.target_rg.id
  principal_id         = azurerm_user_assigned_identity.apim.principal_id
}