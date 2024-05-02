provider "azurerm" {
  features {}
}

provider "azapi" {
  use_msi = false
}

provider "stripe" {
  api_key = var.stripe_api_key
}
