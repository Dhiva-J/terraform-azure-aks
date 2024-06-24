variable "aks_cluster_id" {
  type        = string
  description = "The id of the managed Kubernetes Cluster."
}

variable "node_pools" {
  description = <<-EOF
  Objects for the AKS cluster Additional Node Pools.

  Available options:
  - `vm_size `                      = The SKU which should be used for the Virtual Machines used in this Node Pool.
  - `os_disk_size_gb`               = The Agent Operating System disk size in GB.
  - `enable_autoscaling`            =  Whether to enable auto-scaler.
  - `vnet_subnet_id`                =  The ID of the Subnet where this Node Pool should exist. Changing this forces a new resource to be created.
  - `pod_subnet_id`                 =  The ID of the Subnet where the pods in the Node Pool should exist.
  - `max_pods`                      = The maximum number of pods that can run on each agent.
  - `node_count`                    = The number of nodes which should exist within this Node Pool. Valid values are between 0 and 1000 (inclusive) for user pools and between 1 and 1000 (inclusive) for system pools.
  - `autoscaling_min_nodes`         = The minimum number of nodes which should exist within this Node Pool. Valid values are between 0 and 1000 and must be less than or equal to max_count.
  - `autoscaling_max_nodes`         = The maximum number of nodes which should exist within this Node Pool. Valid values are between 0 and 1000 and must be greater than or equal to min_count.
  - `kube_node_labels`              = A map of Kubernetes labels which should be applied to nodes in this Node Pool.
  EOF

  type = map(object({
    node_count            = number
    vm_size               = string
    os_disk_size_gb       = number
    enable_autoscaling    = bool
    vnet_subnet_id        = string
    pod_subnet_id         = optional(string, null)
    max_pods              = number
    autoscaling_min_nodes = optional(number, 1)
    autoscaling_max_nodes = number
    kube_node_labels      = optional(map(string), {})
  }))
}

variable "enable_availability_zones" {
  type        = bool
  description = "Enable Availability Zones"
  default     = true
}
