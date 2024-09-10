output "id" {
  description = "ID of the machine pool"
  value       = var.hcp ? rhcs_hcp_machine_pool.hcp[0].id : rhcs_machine_pool.classic[0].id
}

output "name" {
  description = "Name of the machine pool"
  value       = var.name
}

output "replicas" {
  description = "Number of replicas in the machine pool"
  value       = var.hcp ? rhcs_hcp_machine_pool.hcp[0].replicas : rhcs_machine_pool.classic[0].replicas
}