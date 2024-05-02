terraform {
  required_providers {
    stripe = {
      version = ">=1.9.6"
      source  = "lukasaron/stripe"
    }
  }
}

resource "stripe_webhook_endpoint" "webhook" {
  url         = var.stripe_webhook_endpoint
  description = "Endpoint URL of the Monetization Server listening subscription changes"
  enabled_events = [
    "customer.subscription.created",
    "customer.subscription.updated",
    "customer.subscription.deleted"
  ]
}

resource "stripe_product" "user_subscription_type" {
  for_each = var.product_list

  product_id  = each.key
  name        = each.value.display_name
  description = each.value.description
}

resource "stripe_price" "product_pricing" {
  for_each = { for i, val in var.monetization_models : i => val }

  product  = each.value.id
  currency = each.value.currency

  recurring {
    interval       = each.value.recurring.interval
    interval_count = each.value.recurring.interval_count
    usage_type     = each.value.recurring.usage_type
  }

  billing_scheme      = each.value.billingScheme
  unit_amount_decimal = each.value.billingScheme == "per_unit" ? each.value.unitAmount : null
  tiers_mode          = each.value.tiersMode

  dynamic "tiers" {
    for_each = each.value.tiers
    content {
      up_to       = tiers.value.upTo
      flat_amount = tiers.value.flatAmount
    }
  }

  depends_on = [stripe_product.user_subscription_type]
}
