variable "ipv4_primary_cidr_block" {
  type        = string
  description = <<-EOT
    The primary IPv4 CIDR block for the VPC.
    Either `ipv4_primary_cidr_block` or `ipv4_primary_cidr_block_association` must be set, but not both.
    EOT
  default     = null
}
# New value trumps old value, but both can be null, so cannot use coalesce()
locals { ipv4_primary_cidr_block = var.ipv4_primary_cidr_block == null ? var.cidr_block : var.ipv4_primary_cidr_block }

variable "ipv4_primary_cidr_block_association" {
  type = object({
    ipv4_ipam_pool_id   = string
    ipv4_netmask_length = number
  })
  description = <<-EOT
    Configuration of the VPC's primary IPv4 CIDR block via IPAM. Conflicts with `ipv4_primary_cidr_block`.
    One of `ipv4_primary_cidr_block` or `ipv4_primary_cidr_block_association` must be set.
    Additional CIDR blocks can be set via `ipv4_additional_cidr_block_associations`.
    EOT
  default     = null
}

variable "ipv4_additional_cidr_block_associations" {
  type = map(object({
    ipv4_cidr_block     = string
    ipv4_ipam_pool_id   = string
    ipv4_netmask_length = number
  }))
  description = <<-EOT
    IPv4 CIDR blocks to assign to the VPC.
    `ipv4_cidr_block` may be set explicitly or derived from `ipv4_ipam_pool_id` using `ipv4_netmask_length`.
    Map keys must be known at `plan` time. When migrating from `additional_cidr_blocks`,
    set map key to `ipv4_cidr_block` value to avoid Terraform changes.
    EOT
  default     = {}
}

variable "ipv4_cidr_block_association_timeouts" {
  type = object({
    create = string
    delete = string
  })
  description = "Timeouts (in `go` duration format) for creating and destroying IPv4 CIDR block associations"
  default     = null
}

variable "assign_generated_ipv6_cidr_block" {
  type        = bool
  description = "Whether to assign generated ipv6 cidr block to the VPC (defaults to `true`).  Conflicts with `ipv6_ipam_pool_id`."
  default     = null
}

# assign_generated_ipv6_cidr_block was only briefly deprecated in favor of ipv6_enabled, so it retains
# precedence. They both defaulted to `true` so we leave the default true.
locals { assign_generated_ipv6_cidr_block = coalesce(var.assign_generated_ipv6_cidr_block, var.ipv6_enabled, true) }

variable "ipv6_primary_cidr_block_association" {
  type = object({
    ipv6_cidr_block     = string
    ipv6_ipam_pool_id   = string
    ipv6_netmask_length = number
  })
  description = <<-EOT
    Primary IPv6 CIDR blocksto assign to the VPC. Conflicts with `assign_generated_ipv6_cidr_block`.
    `ipv6_cidr_block` be set explicitly or derived from `ipv6_ipam_pool_id` using `ipv6_netmask_length`.
    EOT
  default     = null
}

variable "ipv6_additional_cidr_block_associations" {
  type = map(object({
    ipv6_cidr_block     = string
    ipv6_ipam_pool_id   = string
    ipv6_netmask_length = number
  }))
  description = <<-EOT
    IPv6 CIDR blocks to assign to the VPC (in addition to the autogenerated one).
    `ipv6_cidr_block` be set explicitly or derived from `ipv6_ipam_pool_id` using `ipv6_netmask_length`.
    Map keys must be known at `plan` time and are used solely to prevent unnecessary changes.
    EOT
  default     = {}
}

variable "ipv6_cidr_block_association_timeouts" {
  type = object({
    create = string
    delete = string
  })
  description = "Timeouts (in `go` duration format) for creating and destroying IPv6 CIDR block associations"
  default     = null
}

variable "ipv6_cidr_block_network_border_group" {
  type        = string
  description = <<-EOT
    Set this to restrict advertisement of public addresses to specific Network Border Groups such as LocalZones.
    EOT
  default     = null
}

variable "instance_tenancy" {
  type        = string
  description = "A tenancy option for instances launched into the VPC"
  default     = "default"
  validation {
    condition     = contains(["default", "dedicated", "host"], var.instance_tenancy)
    error_message = "Instance tenancy must be one of \"default\", \"dedicated\", or \"host\"."
  }
}

variable "dns_hostnames_enabled" {
  type        = bool
  description = "Whether to enable/disable DNS hostnames in the VPC"
  default     = true
}
locals { dns_hostnames_enabled = coalesce(var.enable_dns_hostnames, var.dns_hostnames_enabled) }

variable "dns_support_enabled" {
  type        = bool
  description = "Whether to enable/disable DNS support in the VPC"
  default     = true
}
locals { dns_support_enabled = coalesce(var.enable_dns_support, var.dns_support_enabled) }

variable "classiclink_enabled" {
  type        = bool
  description = "Whether to enable/disable ClassicLink for the VPC"
  default     = false
}
locals { classiclink_enabled = coalesce(var.enable_classiclink, var.classiclink_enabled) }

variable "classiclink_dns_support_enabled" {
  type        = bool
  description = "Whether to enable/disable ClassicLink DNS Support for the VPC"
  default     = false
}
locals { classiclink_dns_support_enabled = coalesce(var.enable_classiclink_dns_support, var.classiclink_dns_support_enabled) }

variable "default_security_group_deny_all" {
  type        = bool
  default     = true
  description = <<-EOT
    When `true`, manage the default security group and remove all rules, disabling all ingress and egress.
    When `false`, do not manage the default security group, allowing it to be managed by another component
    EOT
}
locals { default_security_group_deny_all = local.enabled && coalesce(var.enable_default_security_group_with_custom_rules, var.default_security_group_deny_all) }

variable "internet_gateway_enabled" {
  type        = bool
  description = "Whether to enable/disable Internet Gateway creation"
  default     = true
}
locals { internet_gateway_enabled = local.enabled && coalesce(var.enable_internet_gateway, var.internet_gateway_enabled) }

variable "ipv6_egress_only_internet_gateway_enabled" {
  type        = bool
  description = "Whether to enable/disable IPv6 Egress-Only Internet Gateway creation"
  default     = false
}

variable "adopt_default_route_table" {
  type        = bool
  description = "Whether to enable/disable adoption of the default route table"
  default     = false
}

variable "adopt_default_network_acl" {
  type        = bool
  description = "Whether to enable/disable adoption of the default network acl"
  default     = false
}

variable "adopt_default_security_group" {
  type        = bool
  description = "Whether to enable/disable adoption of the default security group"
  default     = false
}
