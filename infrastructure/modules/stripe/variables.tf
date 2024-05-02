variable "stripe_webhook_endpoint" {
  type        = string
  description = "Url of the Webhook consumer"
}

variable "product_list" {
  type = map(object({
    display_name = string
    description  = string
  }))
  description = "The list of products. The Key will be used as product_id"
}

variable "monetization_models" {
  type = list(object({
    id               = string
    pricingModelType = string
    billingScheme    = string
    tiersMode        = optional(string, null)
    unitAmount       = optional(number, null)
    currency         = string
    recurring = object({
      interval       = string
      interval_count = number
      usage_type     = string
    })
    tiers = optional(list(object({
      upTo       = number
      flatAmount = number
    })), [])
  }))
  description = "The Pricing model for each product provided in product_list. The Map keys should match the keys in product_list"
}
