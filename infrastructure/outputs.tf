output "web_endpoint" {
  value       = azurerm_storage_account.spa.primary_web_endpoint
  description = "The Single Page Application's Home"
}

output "monetization_server_endpoint" {
  value       = "https://${azurerm_container_app.monetization_server.ingress[0].fqdn}"
  description = "Monetization Server Base URL"
}