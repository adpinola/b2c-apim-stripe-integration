locals {
  server_port = 8000
  stripe_webhook_ips = [
    "3.18.12.63",
    "3.130.192.231",
    "13.235.14.237",
    "13.235.122.149",
    "18.211.135.69",
    "35.154.171.200",
    "52.15.183.38",
    "54.88.130.119",
    "54.88.130.237",
    "54.187.174.169",
    "54.187.205.235",
    "54.187.216.72"
  ]
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
    value = "<unset>"
  }

  secret {
    name  = "stripe-api-key"
    value = "<unset>"
  }

  secret {
    name  = "stripe-webhook-secret"
    value = "<unset>"
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
      ip_address_range = "${module.apim.public_ip_addresses.0}/32"
      name             = "APIM inbound"
    }

    dynamic "ip_security_restriction" {
      for_each = toset(local.stripe_webhook_ips)
      content {
        action           = "Allow"
        ip_address_range = ip_security_restriction.value
        name             = "Stripe Webhook ${ip_security_restriction.key}"
      }
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
        value = module.apim.name
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
        value = module.apim.management_api_url
      }

      env {
        name  = "APIM_GATEWAY_URL"
        value = module.apim.gateway_url
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

  lifecycle {
    ignore_changes = [secret]
  }
}

resource "azurerm_role_assignment" "storage_blob_access" {
  role_definition_name = "API Management Service Contributor"
  scope                = module.apim.instance_id
  principal_id         = azurerm_container_app.monetization_server.identity[0].principal_id
}

resource "azapi_resource_action" "app_secret" {
  type        = "Microsoft.App/containerApps@2024-03-01"
  resource_id = azurerm_container_app.monetization_server.id
  method      = "PATCH"
  body = {
    properties = {
      configuration = {
        secrets = [
          {
            name  = "stripe-webhook-secret"
            value = module.stripe.webhook_secret
          },
          {
            name  = "apim-master-subscription-key"
            value = module.apim.master_subscription_key
          },
          {
            name  = "stripe-api-key"
            value = var.stripe_api_key
          }
        ]
      }
    }
  }

  depends_on = [azurerm_container_app.monetization_server]
}
