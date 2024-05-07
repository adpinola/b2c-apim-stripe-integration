locals {
  stripe_products = {
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

module "stripe" {
  source = "./modules/stripe"

  monetization_models     = jsondecode(file("../payment/monetizationModels.json"))
  product_list            = local.stripe_products
  stripe_webhook_endpoint = "https://${azurerm_container_app.monetization_server.ingress.0.fqdn}/webhook/stripe"

  providers = {
    stripe = stripe
  }
}
