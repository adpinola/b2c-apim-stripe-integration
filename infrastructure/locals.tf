locals {
  location_prefixes = {
    "eastus"        = "eus"
    "eastus2"       = "eus2"
    "westus"        = "wus"
    "westus2"       = "wus2"
    "northeurope"   = "ne"
    "westeurope"    = "we"
    "eastasia"      = "ea"
    "southeastasia" = "sea"
  }

  environment  = "default"
  product_area = "apinola"
  location     = "eastus"

  tags = {
    Environment = local.environment
    ProductArea = local.product_area
    ManagedBy   = "Terraform"
  }
}
