variable "stripe_api_key" {
  type = string
  description = "Value of Stripe 'App Key' API key created as part of pre-requisites"
  default = "sk_test_51OpBzCGxJsfbj48NzApw9WMZ2Se6WbSflg2tJ6LO6u8Oa7UWaijZWXciFUQ8NB8Du1Lox6PPrS9IpzCZ5DuXmHnl004BDZeFxP"
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