module "stripe" {
  source = "./modules/stripe"

  monetization_models     = jsondecode(file("../payment/monetizationModels.json"))
  product_list            = local.products
  stripe_webhook_endpoint = "https://${azurerm_container_app.monetization_server.ingress.0.fqdn}/webhook/stripe"

  providers = {
    stripe = stripe
  }
}
