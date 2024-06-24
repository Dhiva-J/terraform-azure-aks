provider "azurerm" {
  features {}
}

module "aks-node-cep" {
  source = "../"

  aks_cluster_id = "/subscriptions/86c82398-3448-43c6-9f4b-954558c30c5a/resourceGroups/Dhivakar-J-RG/providers/Microsoft.ContainerService/managedClusters/aks-kv-dj-poc"

  node_pools = {
    "pool1" = {
      vm_size               = "Standard_B2s"
      os_disk_size_gb       = 32
      enable_autoscaling    = true
      vnet_subnet_id        = "/subscriptions/86c82398-3448-43c6-9f4b-954558c30c5a/resourceGroups/Dhivakar-J-RG/providers/Microsoft.Network/virtualNetworks/KV-AKS-Vet/subnets/default"
      pod_subnet_id         = null
      max_pods              = null
      node_count            = 2
      autoscaling_min_nodes = 1
      autoscaling_max_nodes = 3
    }
  }
}


data "azurerm_kubernetes_cluster" "cluster" {
  name                = "aks-kv-dj-poc"
  resource_group_name = "Dhivakar-J-RG"
}

provider "kubernetes" {
  host                   = data.azurerm_kubernetes_cluster.cluster.kube_config[0].host
  client_certificate     = base64decode(data.azurerm_kubernetes_cluster.cluster.kube_config[0].client_certificate)
  client_key             = base64decode(data.azurerm_kubernetes_cluster.cluster.kube_config[0].client_key)
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.cluster.kube_config[0].cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = data.azurerm_kubernetes_cluster.cluster.kube_config[0].host
    client_certificate     = base64decode(data.azurerm_kubernetes_cluster.cluster.kube_config[0].client_certificate)
    client_key             = base64decode(data.azurerm_kubernetes_cluster.cluster.kube_config[0].client_key)
    cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.cluster.kube_config[0].cluster_ca_certificate)
  }
}

resource "helm_release" "kubevela" {
  name            = "kubevela"
  repository      = "https://kubevela.github.io/charts"
  chart           = "vela-core"
  namespace       = "vela-system"
  create_namespace = true

  depends_on = [ module.aks-node-cep ]
}

resource "null_resource" "install_kubevela_cli" {
  depends_on = [ module.aks-node-cep ]

  provisioner "local-exec" {
    command = <<EOT
      #!/bin/bash
      # Install Kubevela CLI
      curl -fsSl https://kubevela.io/script/install.sh | bash

      # Enable VelaUX addon
      vela addon enable velaux
      vela addon enable velaux serviceType=LoadBalancer
    EOT
    environment = {
      KUBECONFIG = "${data.azurerm_kubernetes_cluster.cluster.kube_config_raw}"
    }
  }
}