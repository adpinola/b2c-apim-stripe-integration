terraform {
  required_version = ">= 1.7.2"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.101.0"
    }
    azapi = {
      source = "Azure/azapi"
    }
  }
}

data "azurerm_client_config" "current" {}

resource "azurerm_api_management" "main" {
  name                = var.api_management_instance_name
  location            = var.location
  resource_group_name = var.resource_group_name
  publisher_name      = var.publisher_name
  publisher_email     = var.publisher_email

  sku_name = var.sku_name

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.apim.id]
  }

  protocols {
    enable_http2 = true
  }

  tags = var.tags
}

resource "azurerm_api_management_policy" "global" {
  count = var.global_policy_definition != null ? 1 : 0

  api_management_id = azurerm_api_management.main.id
  xml_content       = var.global_policy_definition

  depends_on = [
    azurerm_api_management_named_value.named_values
  ]
}

resource "azurerm_user_assigned_identity" "apim" {
  name                = var.apim_identity_name
  resource_group_name = var.resource_group_name
  location            = var.location
}

data "azapi_resource_action" "master_subscription" {
  type                   = "Microsoft.ApiManagement/service/subscriptions@2023-05-01-preview"
  resource_id            = "${azurerm_api_management.main.id}/subscriptions/master"
  action                 = "listSecrets"
  response_export_values = ["*"]
}
