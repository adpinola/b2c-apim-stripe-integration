terraform {
  required_version = ">= 1.7.2"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.101.0"
    }
  }
}


data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "rg" {
  name     = module.naming.resource_group.name
  location = local.location

  tags     = local.tags
}

module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.0"
  prefix  = [local.product_area, local.environment, local.location_prefixes[local.location]]
}
