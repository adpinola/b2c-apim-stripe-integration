output "instance_id" {
  value = azurerm_api_management.main.id
  description = "The ID of the APIM instance"
}

output "name" {
  value = azurerm_api_management.main.name
  description = "The name of the APIM instance"
}

output "master_subscription_key" {
  value = jsondecode(data.azapi_resource_action.master_subscription.output)["primaryKey"]
}

output "gateway_url" {
  value = azurerm_api_management.main.gateway_url
}

output "management_api_url" {
  value = azurerm_api_management.main.management_api_url
}

output "public_ip_addresses" {
  value = azurerm_api_management.main.public_ip_addresses
}

output "ApimServiceName" {
  value       = azurerm_api_management.main.name
  description = "This Named value is stored in the APIM instance."
}

output "ResourceGroupName" {
  value       = var.resource_group_name
  description = "This Named value is stored in the APIM instance."
}

output "SubscriptionId" {
  value       = data.azurerm_client_config.current.subscription_id
  description = "This Named value is stored in the APIM instance."
}


output "UaiClientId" {
  value       = azurerm_user_assigned_identity.apim.client_id
  description = "This Named value is stored in the APIM instance and can be used to authenticate calls to backends."
}
