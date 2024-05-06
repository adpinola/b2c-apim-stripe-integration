locals {
  server_port = 8000
}

resource "azurerm_container_app_environment" "capp_env" {
  name                = module.naming.container_app_environment.name
  resource_group_name = azurerm_resource_group.rg.name
  location            = local.location
}

resource "azurerm_container_app" "monetization_server" {
  name                         = module.naming.container_app.name
  resource_group_name          = azurerm_resource_group.rg.name
  container_app_environment_id = azurerm_container_app_environment.capp_env.id
  revision_mode                = "Single"

  identity {
    type = "SystemAssigned"
  }

  secret {
    name  = "apim-master-subscription-key"
    value = jsondecode(data.azapi_resource_action.master_subscription.output)["primaryKey"]
  }

  secret {
    name  = "stripe-api-key"
    value = var.stripe_api_key
  }

  secret {
    name  = "stripe-webhook-secret"
    value = var.stripe_webhook_secret
  }

  ingress {
    external_enabled = true
    target_port      = local.server_port

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }

    ip_security_restriction {
      action           = "Allow"
      ip_address_range = "${azurerm_api_management.main.public_ip_addresses.0}/32"
      name             = "APIM inbound"
    }
  }

  template {
    container {
      name   = "monetizationserver"
      image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
      cpu    = 0.25
      memory = "0.5Gi"

      env {
        name  = "NODE_ENV"
        value = "development"
      }

      env {
        name  = "SERVER_PORT"
        value = local.server_port
      }

      env {
        name  = "APIM_SERVICE_NAME"
        value = azurerm_api_management.main.name
      }

      env {
        name  = "APIM_SERVICE_AZURE_SUBSCRIPTION_ID"
        value = data.azurerm_client_config.current.subscription_id
      }

      env {
        name  = "APIM_SERVICE_AZURE_RESOURCE_GROUP_NAME"
        value = azurerm_resource_group.rg.name
      }

      env {
        name  = "APIM_MANAGEMENT_URL"
        value = azurerm_api_management.main.management_api_url
      }

      env {
        name  = "APIM_GATEWAY_URL"
        value = azurerm_api_management.main.gateway_url
      }

      env {
        name        = "APIM_ADMIN_SUBSCRIPTION_KEY"
        secret_name = "apim-master-subscription-key"
      }

      env {
        name  = "STRIPE_PUBLIC_KEY"
        value = var.stripe_public_key
      }

      env {
        name        = "STRIPE_API_KEY"
        secret_name = "stripe-api-key"
      }

      env {
        name        = "STRIPE_WEBHOOK_SECRET"
        secret_name = "stripe-webhook-secret"
      }

      env {
        name  = "ALLOWED_ORIGINS"
        value = "*"
      }
    }
  }
}

resource "azurerm_role_assignment" "storage_blob_access" {
  role_definition_name = "API Management Service Contributor"
  scope                = azurerm_api_management.main.id
  principal_id         = azurerm_container_app.monetization_server.identity[0].principal_id
}
