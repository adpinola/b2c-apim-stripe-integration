variable "stripe_api_key" {
  type = string
  description = "Value of Stripe 'App Key' API key created as part of pre-requisites"
  default = "apikey"
}

variable "stripe_public_key" {
  type = string
  description = "(Value of Stripe 'Publishable key' from Stripe standard keys"
  default = "publickey"
}

variable "stripe_webhook_secret" {
  type = string
  description = "Value of the signing secret for the Stripe webhook created as part of the stripeInitialisation.ps1 script"
  default = "whsecret"
}