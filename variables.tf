# NOTE: the variables in this file are organized in alphabetical order.

variable "auto_upgrade" {
  type        = bool
  default     = false
  nullable    = false
  description = "Enable automatic upgrade of the SKS cluster control plane."
}

variable "cni" {
  type        = string
  default     = "cilium"
  nullable    = false
  description = "Specify which CNI plugin to use (cannot be changed after the first deployment). Accepted values are `calico` or `cilium`. This module creates the required security group rules."

  validation {
    condition     = contains(["calico", "cilium"], var.cni)
    error_message = "The CNI plugin must be either 'calico' or 'cilium'."
  }
}

variable "description" {
  type        = string
  default     = null
  description = "A free-form string description to apply to the SKS cluster."
}

variable "kubeconfig_file_create" {
  description = "Create a Kubeconfig file in the directory where `terraform apply` is run. The file will be named `<cluster_name>-config.yaml`."
  type        = bool
  default     = false
}

variable "kubeconfig_ttl" {
  description = "Validity period of the Kubeconfig file (that is used to create the `kubernetes_*` authentication outputs) in seconds. See https://registry.terraform.io/providers/exoscale/exoscale/latest/docs/resources/sks_kubeconfig#ttl_seconds[official documentation] for more information, namely the effect of setting the TTL."
  type        = number
  default     = 0 # Unlimited lifetime
}

variable "kubeconfig_early_renewal" {
  description = "Renew the Kubeconfig file (that is used to create the `kubernetes_*` authentication outputs) if its age is older than this value in seconds. See https://registry.terraform.io/providers/exoscale/exoscale/latest/docs/resources/sks_kubeconfig#early_renewal_seconds[official documentation] for more information."
  type        = number
  default     = 0
}

variable "kubernetes_version" {
  type        = string
  nullable    = false
  description = "The Kubernetes version to use for the SKS cluster. You can use the https://community.exoscale.com/documentation/tools/exoscale-command-line-interface/[Exoscale CLI] and run `exo compute sks versions` to see the available versions. May only be set at creation time."
}

variable "oidc" {
  type = object({
    client_id       = string
    issuer_url      = string
    groups_claim    = optional(string)
    groups_prefix   = optional(string)
    required_claim  = optional(map(string))
    username_claim  = optional(string)
    username_prefix = optional(string)
  })
  default     = null
  description = "OpenID Connect configuration to allow access to the SKS cluster. Can only be set at creation time."
}

variable "name" {
  type        = string
  nullable    = false
  description = "The name of the SKS cluster."
}

variable "nodepools" {
  type = map(object({
    size                = number
    instance_type       = string
    instance_prefix     = optional(string, null)
    disk_size           = optional(number, 50)
    labels              = optional(map(string), {})
    taints              = optional(map(string), {})
    private_network_ids = optional(list(string), [])
    security_group_ids  = optional(list(string), [])
  }))
  nullable    = false
  description = <<-EOT
    Map containing the SKS node pools to be created.

    Needs to be a map of maps, where the key is the name of the node pool and the value is a map containing at least the keys `instance_type` and `size`.
    The other keys are optional: `description`, `instance_prefix`, `disk_size`, `labels`, `taints`, `private_network_ids` and `security_group_ids`. Check the official documentation https://registry.terraform.io/providers/exoscale/exoscale/latest/docs/resources/sks_nodepool[here] for more information.
  EOT
}

variable "service_level" {
  type        = string
  default     = "pro"
  description = "Choose the service level for the SKS cluster. _Starter_ can be used for test and development purposes, _Pro_ is recommended for production workloads. The official documentation is available https://community.exoscale.com/documentation/sks/overview/#pricing-tiers[here]."

  validation {
    condition     = contains(["starter", "pro"], var.service_level)
    error_message = "The service level must be either 'starter' or 'pro'."
  }
}

variable "zone" {
  type        = string
  nullable    = false
  description = "The name of the zone where to deploy the SKS cluster. Available zones can be consulted https://community.exoscale.com/documentation/sks/overview/#availability[here]."
}
