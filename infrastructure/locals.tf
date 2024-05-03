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

  apim = {
    publisher_email = "alepinola@gmail.com"
    publisher_name  = "Alejandro Pinola"
  }

  tags = {
    Environment = local.environment
    ProductArea = local.product_area
    CreatedBy   = "Terraform"
    CreatedDate = "2024-05-02"
  }
}
