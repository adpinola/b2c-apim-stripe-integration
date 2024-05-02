resource "azurerm_storage_account" "spa" {
  name                     = module.naming.storage_account.name_unique
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = local.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  blob_properties {
    cors_rule {
      allowed_headers    = ["*"]
      allowed_methods    = ["GET", "OPTIONS"]
      allowed_origins    = ["*"]
      exposed_headers    = ["*"]
      max_age_in_seconds = 600
    }
  }

  static_website {
    index_document     = "index.html"
    error_404_document = "404.html"
  }
}

resource "azurerm_storage_blob" "index" {
  name                   = "index.html"
  storage_account_name   = azurerm_storage_account.spa.name
  storage_container_name = "$web"
  type                   = "Block"

  source_content = templatefile("../spa/index.html", {
    B2C_CLIENT_ID      = var.b2c.audience
    B2C_TENANT_NAME    = var.b2c.tenant_name
    B2C_POLICY_ID      = var.b2c.policy_id
    FRONTEND_URI       = azurerm_storage_account.spa.primary_web_endpoint
    PAYMENT_SERVER_URL = "https://${azurerm_container_app.monetization_server.ingress[0].fqdn}/subscribe"
    SCOPES             = jsonencode(var.backend_scopes)
    BACKEND_URL        = "${module.apim.gateway_url}/example"
  })
  content_type = "text/html"
}
