locals {
  products = {
    "admin" = {
      display_name = "Admin"
      description  = "Admin"
    }
    "free" = {
      display_name = "Free"
      description  = "Free tier with a monthly quota of 100 calls."
    }
    "developer" = {
      display_name = "Developer"
      description  = "Developer tier with a free monthly quota of 100 calls and charges for overage."
    }
    "payg" = {
      display_name = "PAYG"
      description  = "Pay-as-you-go tier."
    }
    "basic" = {
      display_name = "Basic"
      description  = "Basic tier with a monthly quota of 50,000 calls."
    }
    "standard" = {
      display_name = "Standard"
      description  = "Standard tier with a monthly quota of 100,000 calls and charges for overage."
    }
    "pro" = {
      display_name = "Pro"
      description  = "Pro tier with a monthly quota of 500,000 calls and charges for overage."
    }
    "enterprise" = {
      display_name = "Enterprise"
      description  = "Enterprise tier with a monthly quota of 1,500,000 calls. Overage is charged in units of 1,500,000 calls."
    }
  }
}

resource "azurerm_api_management_product" "api_product" {
  for_each = local.products

  api_management_name = azurerm_api_management.main.name
  resource_group_name = azurerm_resource_group.rg.name
  product_id          = each.key
  display_name        = each.value.display_name
  description         = each.value.description

  subscription_required = true
  approval_required     = each.key == "admin" ? true : false
  subscriptions_limit   = each.key == "admin" ? 1 : null
  published             = true
}

resource "azurerm_api_management_product_policy" "api_product_policy" {
  for_each = azurerm_api_management_product.api_product

  product_id          = each.value.product_id
  api_management_name = azurerm_api_management.main.name
  resource_group_name = azurerm_resource_group.rg.name

  xml_content = file("./api-policy/products/${each.value.product_id}.xml")
}

resource "azurerm_api_management_product_api" "billing_api_assignment" {
  for_each = azurerm_api_management_product.api_product

  product_id          = each.value.product_id
  api_management_name = azurerm_api_management.main.name
  resource_group_name = azurerm_resource_group.rg.name
  api_name            = azurerm_api_management_api.billing_api.name
}

resource "azurerm_api_management_product_api" "monetization_api_assignment" {
  for_each = azurerm_api_management_product.api_product

  product_id          = each.value.product_id
  api_management_name = azurerm_api_management.main.name
  resource_group_name = azurerm_resource_group.rg.name
  api_name            = azurerm_api_management_api.monetization.name
}
