locals {
  aks_node_pool_ids = { for pool_name, pool_config in var.node_pools : pool_name => azurerm_kubernetes_cluster_node_pool.node_pools[pool_name].id }
}