resource "azurerm_kubernetes_cluster_node_pool" "node_pools" {
  for_each = var.node_pools

  name                  = each.key
  kubernetes_cluster_id = var.aks_cluster_id

  vm_size               = each.value.vm_size
  node_count            = each.value.node_count
  os_disk_size_gb       = each.value.os_disk_size_gb
  vnet_subnet_id        = each.value.vnet_subnet_id
  pod_subnet_id         = each.value.pod_subnet_id
  zones                 = var.enable_availability_zones ? ["1", "2", "3"] : null
  os_type               = "Linux"
  enable_node_public_ip = false

  node_labels = each.value.kube_node_labels

  enable_auto_scaling = each.value.enable_autoscaling
  max_count           = each.value.enable_autoscaling ? each.value.autoscaling_max_nodes : null
  min_count           = each.value.enable_autoscaling ? each.value.autoscaling_min_nodes : null
  max_pods            = each.value.max_pods

}