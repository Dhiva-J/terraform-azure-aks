provider "azurerm" {
  features {}
}

module "aks" {
  source = "../"

  aks_cluster = {
    cluster_name               = "kv-dj-poc"
    automatic_channel_upgrade  = "patch"
    kubernetes_version         = "1.28.5"
  }

  rg_name  = "Dhivakar-J-RG"
  location = "East US"

  network_settings = {
    network_plugin = "azure"
  }


  default_node_pool = {
    name       = "default"
    node_count = 1
    temporary_name_for_rotation = "testing"
    subnet_id  = "/subscriptions/86c82398-3448-43c6-9f4b-954558c30c5a/resourceGroups/Dhivakar-J-RG/providers/Microsoft.Network/virtualNetworks/KV-AKS-Vet/subnets/default"
  }
}

output "kube_config" {
  value     = module.aks.kube_config
}