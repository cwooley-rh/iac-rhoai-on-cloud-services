variable "cluster_id" {
  type        = string
  description = "ID of the cluster"
}

variable "name" {
  type        = string
  description = "Name of the machine pool"
}

variable "machine_type" {
  type        = string
  description = "Machine type for the nodes"
}

variable "replicas" {
  type        = number
  description = "Number of replicas"
  default     = null
}

variable "autoscaling_enabled" {
  type        = bool
  description = "Enable autoscaling"
  default     = false
}

variable "min_replicas" {
  type        = number
  description = "Minimum number of replicas for autoscaling"
  default     = null
}

variable "max_replicas" {
  type        = number
  description = "Maximum number of replicas for autoscaling"
  default     = null
}

variable "labels" {
  type        = map(string)
  description = "Labels for the machine pool"
  default     = {}
}

variable "taints" {
  type = list(object({
    key    = string
    value  = string
    effect = string
  }))
  description = "Taints for the machine pool"
  default     = []
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID for the machine pool"
  default     = null
}

variable "availability_zone" {
  type        = string
  description = "Availability zone for the machine pool"
  default     = null
}

variable "disk_size" {
  type        = number
  description = "Disk size in GiB"
  default     = null
}

variable "additional_security_group_ids" {
  type        = list(string)
  description = "Additional security group IDs"
  default     = []
}

variable "hcp" {
  type        = bool
  description = "Whether this is an HCP cluster"
  default     = false
}

variable "auto_repair" {
  type        = bool
  description = "Enable auto repair"
  default     = true
}

variable "version" {
  type        = string
  description = "OpenShift version for HCP machine pool"
  default     = null
}