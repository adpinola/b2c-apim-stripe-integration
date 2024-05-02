locals {
  server_port = 8000
}

data "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = var.acr_rg
}

resource "azurerm_user_assigned_identity" "containerapp" {
  location            = local.location
  name                = "${module.naming.container_app.name}-uai"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_role_assignment" "containerapp" {
  scope                = data.azurerm_container_registry.acr.id
  role_definition_name = "acrpull"
  principal_id         = azurerm_user_assigned_identity.containerapp.principal_id

  depends_on = [
    azurerm_user_assigned_identity.containerapp
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
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.containerapp.id]
  }

  registry {
    server   = data.azurerm_container_registry.acr.login_server
    identity = azurerm_user_assigned_identity.containerapp.id
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
  }

  template {
    container {
      name   = "monetizationserver"
      image  = "${data.azurerm_container_registry.acr.login_server}/${var.image_name}:latest"
      cpu    = 0.25
      memory = "0.5Gi"

      env {
        name  = "NODE_ENV"
        value = "development"
      }

      env {
        name  = "HOME_PAGE"
        value = azurerm_storage_account.spa.primary_web_endpoint
      }

      env {
        name  = "SERVER_PORT"
        value = local.server_port
      }

      env {
        name  = "AZURE_CLIENT_ID"
        value = azurerm_user_assigned_identity.containerapp.client_id
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

resource "azurerm_role_assignment" "apim_contributor" {
  role_definition_name = "API Management Service Contributor"
  scope                = module.apim.instance_id
  principal_id         = azurerm_user_assigned_identity.containerapp.principal_id
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
