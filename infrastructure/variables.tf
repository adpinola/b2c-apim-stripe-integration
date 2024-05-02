variable "stripe_api_key" {
  type        = string
  description = "Value of Stripe 'App Key' API key created as part of pre-requisites"
}

variable "stripe_public_key" {
  type        = string
  description = "Value of Stripe 'Publishable key' from Stripe standard keys"
}

variable "acr_name" {
  type        = string
  description = "The ACR Name where the Monetization Server is available"
}

variable "acr_rg" {
  type        = string
  description = "The Resource Group where the ACR Exists"
}

variable "image_name" {
  type        = string
  description = "The Image Name of the Monetization Server"
}

variable "b2c" {
  type = object({
    audience    = string
    tenant_name = string
    policy_id   = string
    issuer      = string
  })
  description = "The B2C Data to configure the SPA"
}

variable "backend_scopes" {
  type        = list(string)
  description = "A list of Backend Scopes to Authenticate the SPA"
}
