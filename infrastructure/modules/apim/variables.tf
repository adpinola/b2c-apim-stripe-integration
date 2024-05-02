variable "api_management_instance_name" {
  description = "The name for the APIM instance."
  type        = string
}

variable "apim_identity_name" {
  description = "The name for the APIM User Assigned Identity."
  type        = string
}

variable "resource_group_name" {
  description = "Resource Group to deploy the APIM instance."
  type        = string
}

variable "location" {
  description = "Azure Region to deploy the APIM instance."
  type        = string
}

variable "sku_name" {
  type        = string
  description = "the SKU for the APIM Instance"
}

variable "roles" {
  description = "Built-in roles to assign to the APIM User Assigned Identity. These will be granted at resource group level."
  type        = list(string)
  default     = []
}

variable "publisher_email" {
  description = "Publisher's Email."
  type        = string
}

variable "publisher_name" {
  description = "Publisher's Name."
  type        = string
}

variable "global_policy_definition" {
  description = "A global policy definition for the APIM instance"
  type        = string
  default     = null
}

variable "products" {
  description = "APIM Products."
  type = map(object({
    display_name          = string
    description           = string
    subscription_required = bool
    approval_required     = optional(bool, false)
    subscriptions_limit   = optional(number, null)
    published             = optional(bool, true)
    api_names             = optional(list(string), [])
    policy_definition     = optional(string, null)
  }))
  default = {}
}

variable "apis" {
  description = "APIs to integrate in the APIM instance."
  type = map(object({
    description       = string
    backend_protocol  = optional(string, null)
    backend_url       = optional(string, null)
    api_protocols     = list(string)
    api_path          = string
    api_definition    = string
    policy_definition = optional(string, null)
    subscription_required = optional(bool, true)
  }))
  default = {}
}

variable "operation_policies" {
  description = "Policies scoped to a specific operation within an API"
  type = map(object({
    api_name          = string
    policy_definition = string
  }))
  default = {}
}

variable "named_values" {
  description = "A list of key-value pairs to save in the APIM instance."
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags to assign to the APIM instance"
  type        = map(string)
  default     = {}
}
