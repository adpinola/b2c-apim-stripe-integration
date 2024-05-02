output "webhook_secret" {
  value     = stripe_webhook_endpoint.webhook.secret
  sensitive = true
}
