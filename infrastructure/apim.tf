module "apim" {
  source = "./modules/apim"

  api_management_instance_name = module.naming.api_management.name
  apim_identity_name           = module.naming.user_assigned_identity.name
  location                     = local.location
  resource_group_name          = azurerm_resource_group.rg.name
  publisher_name               = local.apim.publisher_name
  publisher_email              = local.apim.publisher_email
  sku_name                     = "Developer_1"

  roles                    = ["Reader"]
  global_policy_definition = file("./api-policy/global.xml")

  apis = {
    "billing" = {
      description    = "Obtain Billing information of this API"
      api_path       = "billing"
      api_protocols  = ["https"]
      api_definition = file("./api-definition/billing.yaml")
    }
    "monetization" = {
      description       = "Monetization Server API"
      api_protocols     = ["https"]
      api_path          = "monetize"
      api_definition    = file("./api-definition/capp.yaml")
      backend_protocol  = "http"
      backend_url       = "https://${azurerm_container_app.monetization_server.ingress.0.fqdn}"
      policy_definition = file("./api-policy/capp.xml")
    }
  }

  operation_policies = {
    "get_monetization_models" = {
      api_name          = "billing"
      policy_definition = file("./api-policy/billing-get_monetization_models.xml")
    }
    "get_products" = {
      api_name          = "billing"
      policy_definition = file("./api-policy/billing-get_products.xml")
    }
  }

  products = {
    "admin" = {
      display_name          = local.stripe_products.admin.display_name
      description           = local.stripe_products.admin.description
      approval_required     = true
      subscriptions_limit   = 1
      subscription_required = true
      published             = true
      policy_definition     = file("./api-policy/products/admin.xml")
      api_names             = ["billing", "monetization"]
    }
    "free" = {
      display_name          = local.stripe_products.free.display_name
      description           = local.stripe_products.free.description
      subscription_required = true
      published             = true
      policy_definition     = file("./api-policy/products/free.xml")
      api_names             = ["billing", "monetization"]
    }
    "developer" = {
      display_name          = local.stripe_products.developer.display_name
      description           = local.stripe_products.developer.description
      subscription_required = true
      published             = true
      policy_definition     = file("./api-policy/products/developer.xml")
      api_names             = ["billing", "monetization"]
    }
    "payg" = {
      display_name          = local.stripe_products.payg.display_name
      description           = local.stripe_products.payg.description
      subscription_required = true
      published             = true
      policy_definition     = file("./api-policy/products/payg.xml")
      api_names             = ["billing", "monetization"]
    }
    "basic" = {
      display_name          = local.stripe_products.basic.display_name
      description           = local.stripe_products.basic.description
      subscription_required = true
      published             = true
      policy_definition     = file("./api-policy/products/basic.xml")
      api_names             = ["billing", "monetization"]
    }
    "standard" = {
      display_name          = local.stripe_products.standard.display_name
      description           = local.stripe_products.standard.description
      subscription_required = true
      published             = true
      policy_definition     = file("./api-policy/products/standard.xml")
      api_names             = ["billing", "monetization"]
    }
    "pro" = {
      display_name          = local.stripe_products.pro.display_name
      description           = local.stripe_products.pro.description
      subscription_required = true
      published             = true
      policy_definition     = file("./api-policy/products/pro.xml")
      api_names             = ["billing", "monetization"]
    }
    "enterprise" = {
      display_name          = local.stripe_products.enterprise.display_name
      description           = local.stripe_products.enterprise.description
      subscription_required = true
      published             = true
      policy_definition     = file("./api-policy/products/enterprise.xml")
      api_names             = ["billing", "monetization"]
    }
  }

  named_values = {
    "MonetizationModels" = file("../payment/monetizationModels.json")
    "AppServiceName"     = azurerm_container_app.monetization_server.name
  }

  providers = {
    azurerm = azurerm
    azapi   = azapi
  }

  tags = local.tags
}
