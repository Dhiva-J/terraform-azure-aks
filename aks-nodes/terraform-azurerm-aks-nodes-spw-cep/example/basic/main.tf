provider "azurerm" {
  features {}
}

variable "TERRATEST_UNIQUE_ID" {
  description = "Terratest Unique ID"
  type        = string
}

variable "DD_API_KEY" {
  description = "DataDog API Key"
  type        = string
}

variable "DD_APP_KEY" {
  description = "DataDog APP Key"
  type        = string
}

variable "WIZ_K8S_CLIENT_ID" {
  description = "WIZ Client Id"
  type        = string
}

variable "WIZ_K8S_CLIENT_SECRET" {
  description = "Wiz Client Secret"
  type        = string
}

locals {
  tags = {
    App_Name             = "terratest"
    App_Env              = "test"
    ServiceNow_Workgroup = "None"
  }
}

data "terraform_remote_state" "aks_cluster" {
  backend = "remote"

  config = {
    hostname     = "app.terraform.io"
    organization = "AIZ"
    workspaces = {
      name = "ephemeral-aks-cluster"
    }
  }
}

module "aks-node-cep" {
  source = "../../"

  aks_cluster_id = data.terraform_remote_state.aks_cluster.outputs.aks_cluster_id

  node_pools = {
    "pool1" = {
      vm_size               = "Standard_D2_v2"
      os_disk_size_gb       = 32
      enable_autoscaling    = true
      vnet_subnet_id        = "/subscriptions/3c51cc28-d5df-44bb-b15c-cfdd64fff599/resourceGroups/RGSPOKE-CENTRALUS-VDC-SERVICES-MODEL/providers/Microsoft.Network/virtualNetworks/vnet-centralus-vdc-services-model/subnets/kubernetes-services-1"
      pod_subnet_id         = null
      max_pods              = null
      node_count            = 1
      autoscaling_min_nodes = 1
      autoscaling_max_nodes = 3
    }
  }

  tags = local.tags

  datadog = ({
    dd_site    = "us3.datadoghq.com"
    dd_api_key = var.DD_API_KEY
    dd_app_key = var.DD_APP_KEY
  })
  wiz = ({
    wiz_client_id     = var.WIZ_K8S_CLIENT_ID
    wiz_client_secret = var.WIZ_K8S_CLIENT_SECRET
  })
}

provider "kubernetes" {
  host                   = data.terraform_remote_state.aks_cluster.outputs.aks_cluster_admin_host
  client_certificate     = base64decode(data.terraform_remote_state.aks_cluster.outputs.aks_cluster_admin_client_certificate)
  client_key             = base64decode(data.terraform_remote_state.aks_cluster.outputs.aks_cluster_admin_client_key)
  cluster_ca_certificate = base64decode(data.terraform_remote_state.aks_cluster.outputs.aks_cluster_admin_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = data.terraform_remote_state.aks_cluster.outputs.aks_cluster_admin_host
    client_certificate     = base64decode(data.terraform_remote_state.aks_cluster.outputs.aks_cluster_admin_client_certificate)
    client_key             = base64decode(data.terraform_remote_state.aks_cluster.outputs.aks_cluster_admin_client_key)
    cluster_ca_certificate = base64decode(data.terraform_remote_state.aks_cluster.outputs.aks_cluster_admin_ca_certificate)
  }
}