locals {
  autoscaling = var.autoscaling_enabled ? {
    enabled      = true
    min_replicas = var.min_replicas
    max_replicas = var.max_replicas
  } : null
}

resource "rhcs_machine_pool" "classic" {
  count = var.hcp ? 0 : 1

  cluster      = var.cluster_id
  name         = var.name
  machine_type = var.machine_type
  replicas     = var.replicas

  autoscaling_enabled = var.autoscaling_enabled
  min_replicas        = var.min_replicas
  max_replicas        = var.max_replicas

  labels = var.labels
  taints = var.taints

  subnet_id         = var.subnet_id
  availability_zone = var.availability_zone

  disk_size = var.disk_size

  aws_additional_security_group_ids = var.additional_security_group_ids
}

resource "rhcs_hcp_machine_pool" "hcp" {
  count = var.hcp ? 1 : 0

  cluster = var.cluster_id
  name    = var.name

  autoscaling = local.autoscaling
  replicas    = var.replicas

  aws_node_pool = {
    instance_type = var.machine_type
  }

  labels = var.labels
  taints = var.taints

  subnet_id = var.subnet_id

  auto_repair = var.auto_repair
  version     = var.version
}