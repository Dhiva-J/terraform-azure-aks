output "cluster_id" {
  description = "Kubernetes Managed Cluster ID"
  value       = azurerm_kubernetes_cluster.cluster.id
}

output "kube_config" {
  description = "Raw Cluster Kubeconfig"
  value       = nonsensitive(azurerm_kubernetes_cluster.cluster.kube_admin_config_raw)
}