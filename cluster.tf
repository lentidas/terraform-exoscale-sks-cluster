resource "exoscale_sks_cluster" "this" {
  zone          = var.zone
  name          = var.name
  description   = var.description
  version       = var.kubernetes_version
  auto_upgrade  = var.auto_upgrade
  service_level = var.service_level
  cni           = var.cni

  dynamic "oidc" {
    for_each = var.oidc != null ? [var.oidc] : []

    content {
      client_id       = oidc.value.client_id
      issuer_url      = oidc.value.issuer_url
      groups_claim    = oidc.value.groups_claim
      groups_prefix   = oidc.value.groups_prefix
      required_claim  = oidc.value.required_claim
      username_claim  = oidc.value.username_claim
      username_prefix = oidc.value.username_prefix
    }
  }
}

resource "exoscale_anti_affinity_group" "this" {
  for_each = var.nodepools

  name        = format("nodepool-%s", each.key)
  description = "Anti-affinity group to prevent the ${each.key} nodes running on the same physical host."
}

resource "exoscale_sks_nodepool" "this" {
  for_each = var.nodepools

  zone                    = var.zone
  cluster_id              = resource.exoscale_sks_cluster.this.id
  anti_affinity_group_ids = [resource.exoscale_anti_affinity_group.this[each.key].id]

  name                = each.key
  instance_prefix     = each.value.instance_prefix == null ? each.key : each.value.instance_prefix
  size                = each.value.size
  instance_type       = each.value.instance_type
  disk_size           = each.value.disk_size
  private_network_ids = each.value.private_network_ids
  security_group_ids  = concat([resource.exoscale_security_group.this.id], each.value.security_group_ids)

  description = "SKS nodepool attached to the ${var.name} cluster (UUID: ${resource.exoscale_sks_cluster.this.id})."
  labels = merge(
    {
      "lentidas-stack.io"          = "true"
      "lentidas-stack.io/cluster"  = var.name
      "lentidas-stack.io/nodepool" = each.key
    },
    each.value.labels
  )
  taints = each.value.taints
}

resource "exoscale_sks_kubeconfig" "this" {
  cluster_id = resource.exoscale_sks_cluster.this.id
  zone       = resource.exoscale_sks_cluster.this.zone

  # User and groups values are the same values as in the official SKS example
  user   = "kubernetes-admin"
  groups = ["system:masters"]

  # Define a lifetime for the generated kubeconfig file
  ttl_seconds           = var.kubeconfig_ttl
  early_renewal_seconds = var.kubeconfig_early_renewal
}
