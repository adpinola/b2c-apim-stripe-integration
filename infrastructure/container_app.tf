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

  ingress {
    external_enabled = true
    target_port      = 80

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  template {
    container {
      name   = "monetizationserver"
      image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
      cpu    = 0.25
      memory = "0.5Gi"
    }
  }
}

resource "azurerm_role_assignment" "storage_blob_access" {
  role_definition_name = "API Management Service Contributor"
  scope                = azurerm_api_management.main.id
  principal_id         = azurerm_container_app.monetization_server.identity[0].principal_id
}
