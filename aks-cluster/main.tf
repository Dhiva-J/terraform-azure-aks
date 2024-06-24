resource "azurerm_kubernetes_cluster" "cluster" {
  name                = "aks-${var.aks_cluster.cluster_name}"
  location            = var.location
  resource_group_name = var.rg_name

  kubernetes_version = var.aks_cluster.kubernetes_version
  # Per design, private_cluster must be enabled
  private_cluster_enabled             = true
  private_dns_zone_id                 = "None"
  private_cluster_public_fqdn_enabled = true
  # Per design, only standard tier is allowed
  sku_tier = "Standard"

  local_account_disabled = var.aks_cluster.local_account_disabled

  automatic_channel_upgrade = var.aks_cluster.automatic_channel_upgrade
  dns_prefix                = "aks${var.aks_cluster.cluster_name}"

  default_node_pool {
    name                         = var.default_node_pool.name
    node_count                   = var.default_node_pool.node_count
    vm_size                      = var.default_node_pool.vm_size
    type                         = var.default_node_pool.vm_type
    os_disk_size_gb              = var.default_node_pool.os_disk_size_gb
    vnet_subnet_id               = var.default_node_pool.subnet_id
    pod_subnet_id                = var.default_node_pool.pod_subnet_id
    zones                        = var.aks_cluster.zones
    enable_auto_scaling          = var.default_node_pool.enable_autoscaling
    max_count                    = var.default_node_pool.enable_autoscaling ? var.default_node_pool.autoscaling_max_nodes : null
    min_count                    = var.default_node_pool.enable_autoscaling ? var.default_node_pool.autoscaling_min_nodes : null
    max_pods                     = var.default_node_pool.max_pods
    enable_node_public_ip        = false
    only_critical_addons_enabled = true

    node_labels = var.default_node_pool.kube_node_labels
    temporary_name_for_rotation = var.default_node_pool.temporary_name_for_rotation
  }

  identity {
    type = "SystemAssigned"
  }


  dynamic "ingress_application_gateway" {
    for_each = var.network_settings.appgw_subnet_id != "" ? [0] : []
    content {
      subnet_id = var.network_settings.appgw_subnet_id
    }
  }

  network_profile {
    network_plugin     = lower(var.network_settings.network_plugin)
    network_policy     = lower(var.network_settings.network_plugin) == "azure" ? "azure" : "calico"
    dns_service_ip     = var.network_settings.dns_service_ip
    pod_cidr           = lower(var.network_settings.network_plugin) == "kubenet" ? var.network_settings.pod_cidr : null
    service_cidr       = var.network_settings.service_cidr
  }
}

# resource "local_file" "kubeconfig" {
#   content  = azurerm_kubernetes_cluster.cluster.kube_admin_config_raw
#   filename = "${path.module}/kubeconfig"
# }

# provider "kubernetes" {
#   config_path = local_file.kubeconfig.filename
# }

# provider "helm" {
#   kubernetes {
#     config_path = local_file.kubeconfig.filename
#   }
# }

# resource "helm_release" "kubevela" {
#   name            = "kubevela"
#   repository      = "https://kubevela.github.io/charts"
#   chart           = "vela-core"
#   namespace       = "vela-system"
#   create_namespace = true
# }

# resource "null_resource" "install_kubevela_cli" {
#   #depends_on = [helm_release.kubevela]

#   provisioner "local-exec" {
#     command = <<EOT
#       #!/bin/bash
#       # Install Kubevela CLI
#       curl -fsSl https://kubevela.io/script/install.sh | bash

#       # Enable VelaUX addon
#       vela addon enable velaux
#       vela addon enable velaux serviceType=LoadBalancer
#     EOT
#     environment = {
#       KUBECONFIG = "${local_file.kubeconfig.filename}"
#     }
#   }
# }