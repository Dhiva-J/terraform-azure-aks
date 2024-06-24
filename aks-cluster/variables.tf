variable "rg_name" {
  type        = string
  description = "Resource Group Name"
}

variable "location" {
  type        = string
  description = "Cluster Location"
}

variable "aks_cluster" {
  description = <<-EOF
  Objects for the AKS cluster.

  Available options:
  - `cluster_name`              = (Required|string) Cluster Name.
  - `automatic_channel_upgrade` = (Required|string) The upgrade channel for this Kubernetes Cluster. Possible values are patch, rapid, node-image and stable. Defaults to none.
  - `kubernetes_version`        = (Optional|string) Kubernetes version to deploy.
  - `local_account_disabled`    = (Optional|string) Disable local account for node authentication. Default to false.
  - `zones`                     = (Optional|string) Availability Zones. Default to ["1", "2", "3"].

  Example:
  ```
  aks_cluster = ({    
    cluster_name                = "testing"
    kubernetes_version          = "1.26.6"
    automatic_channel_upgrade   = "patch"
    local_account_disabled      = false
    zones                       = ["1", "2"]
  })
  ```
  EOF

  type = object({
    cluster_name               = string
    automatic_channel_upgrade  = string
    kubernetes_version         = optional(string, "1.28.5")
    local_account_disabled     = optional(bool, false)
    zones                      = optional(list(string), ["1", "2", "3"])
  })

  validation {
    condition     = contains(["patch", "rapid", "node-image", "stable", "none"], lower(var.aks_cluster.automatic_channel_upgrade))
    error_message = "The value must be a valid string. patch, rapid, node-image or stable. Defaults to none."
  }
}


variable "network_settings" {
  description = <<-EOF
  Objects for the AKS cluster network Settings.

  Available options:
  - `network_plugin`        = (optional|string) Network plugin to use. Options: kubenet or azure (default).
  - `dns_service_ip`        = (optional|string) DNS Service IP (typically in var.service_cidr ending in .10).
  - `docker_bridge_cidr`    = (optional|string) Docker Bridge CIDR range.
  - `pod_cidr`              = (optional|string) Pod  CIDR range. if `network_plugin` = "kubenet", then pod cidr range is required.
  - `service_cidr`          = (optional|string) Service  CIDR range.
  - `appgw_subnet_id`       = (optional|string) Application Gateway Subnet ID. Specifying this creates an application gateway.

  Example:
  ```
  network_settings = ({    
    network_plugin       = "azure"
    pod_cidr             = null
  })
  ```
  EOF

  type = object({
    network_plugin     = optional(string, "azure")
    dns_service_ip     = optional(string, "172.16.0.10")
    pod_cidr           = optional(string, null)
    service_cidr       = optional(string, "172.16.0.0/16")
    appgw_subnet_id    = optional(string, "")
  })

  validation {
    condition     = contains(["azure", "kubenet"], lower(var.network_settings.network_plugin))
    error_message = "Currently supported values are azure and kubenet. Defaults to azure."
  }

  validation {
    condition     = var.network_settings.network_plugin == "kubenet" ? var.network_settings.pod_cidr != null : true
    error_message = "Error: Required the input for Pod Cidr as it is defined to value null"
  }
}

variable "default_node_pool" {
  description = <<-EOF
  Objects for the AKS cluster default Node Pools.

  Available options:
  - `name`                          = The name of the Node Pool which should be created within the Kubernetes Cluster. 
  - `vm_size `                      = The SKU which should be used for the Virtual Machines used in this Node Pool. Default to Standard_DS4_v2.
  - `vm_type`                       = The type of Default Node Pool for the Kubernetes Cluster must be VirtualMachineScaleSets to attach multiple node pools. Default to VirtualMachineScaleSets.
  - `os_disk_size_gb`               = The Agent Operating System disk size in GB.
  - `subnet_id`                     = The ID of the Subnet where this Node Pool should exist.
  - `pod_subnet_id`                 = The ID of the Subnet where the pods in the default Node Pool should exist.
  - `enable_autoscaling`            =  Whether to enable auto-scaler. Default to false.
  - `max_pods`                      = The maximum number of pods that can run on each agent. Default to 30.
  - `node_count`                    = The number of nodes which should exist within this Node Pool. Valid values are between 0 and 1000 (inclusive) for user pools and between 1 and 1000 (inclusive) for system pools. Default to 3.
  - `autoscaling_min_nodes`         = The minimum number of nodes which should exist within this Node Pool. Valid values are between 0 and 1000 and must be less than or equal to max_count. Default to null.
  - `autoscaling_max_nodes`         = The maximum number of nodes which should exist within this Node Pool. Valid values are between 0 and 1000 and must be greater than or equal to min_count. Default to 1.
  - `kube_node_labels`              = A map of Kubernetes labels which should be applied to nodes in this Node Pool.
  - 'temporary_name_for_rotation'   = When updating above paraemters, temporary_name_for_rotation must be specified fo the rotation
  - `only_critical_addons_enabled`  = Enabling this option will taint default node pool with CriticalAddonsOnly=true:NoSchedule taint. Default to true.
  EOF

  type = object({
    name                         = optional(string, "default")
    node_count                   = optional(number, 3)
    vm_size                      = optional(string, "Standard_B2s")
    vm_type                      = optional(string, "VirtualMachineScaleSets")
    os_disk_size_gb              = optional(number, 32)
    subnet_id                    = string
    pod_subnet_id                = optional(string, null)
    enable_autoscaling           = optional(bool, false)
    max_pods                     = optional(number, 30)
    autoscaling_min_nodes        = optional(number, 1)
    autoscaling_max_nodes        = optional(number, null)
    kube_node_labels             = optional(map(string), {})
    only_critical_addons_enabled = optional(bool, true)
    temporary_name_for_rotation  = optional(string, null)    
  })
}