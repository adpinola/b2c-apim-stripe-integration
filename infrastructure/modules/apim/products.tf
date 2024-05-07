locals {
  all_apis = flatten([
    for product_key, product_value in var.products : [
      for api in product_value.api_names : {
        product_id = product_key
        api_name   = api
      }
    ]
  ])
}

resource "azurerm_api_management_product" "api_product" {
  for_each = var.products

  api_management_name = azurerm_api_management.main.name
  resource_group_name = var.resource_group_name
  product_id          = each.key
  display_name        = each.value.display_name
  description         = each.value.description

  subscription_required = each.value.subscription_required
  approval_required     = each.value.approval_required
  subscriptions_limit   = each.value.subscriptions_limit
  published             = each.value.published
}

resource "azurerm_api_management_product_policy" "api_product_policy" {
  for_each = var.products

  product_id          = each.key
  api_management_name = azurerm_api_management.main.name
  resource_group_name = var.resource_group_name

  xml_content = each.value.policy_definition

  depends_on = [
    azurerm_api_management_product.api_product,
    azurerm_api_management_named_value.named_values
  ]
}

resource "azurerm_api_management_product_api" "product_apis" {
  for_each = {
    for api in local.all_apis : "${api.product_id}-${api.api_name}" => api
  }

  product_id          = each.value.product_id
  api_management_name = azurerm_api_management.main.name
  resource_group_name = var.resource_group_name
  api_name            = each.value.api_name

  depends_on = [azurerm_api_management_product_policy.api_product_policy]
}
