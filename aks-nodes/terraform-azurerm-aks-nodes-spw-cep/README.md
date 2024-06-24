# terraform-azurerm-aks-nodes-spw-cep
Link to Confluence Pattern: https://confluence.assurant.com/display/aecpe/Azure+Kubernetes+Services+%28AKS%29+Design

## Summary
This pattern deploys an Azure Kubernetes Services (AKS) Node Deployment along with Datadog and Wiz integration.

## Benefits
* AKS Cluster Node Deployment along with Datadog and WIZ Integration.

## Feature Implementation Matrix
The following table highlights high level features and their implementation status. Additional features will be implemented based on identified user requirements.
| Feature | Status |
|---|---|
| Additional Nodes for the existing Cluster must be configured to auto-upgrade| Implemented |
| Configures Datadog and Wiz integration on AKS cluster | Implemented |

## Pre-requisites
* Existing Cluster name
* Resource Group where cluster is deployed

## Supported Terraform version: {TF version}

| Provider | Version |
|---|---|
| `azurerm` | `~> 3.0` |
| `azuread` | `~> 2.0` |
| `kubernetes` | `~> 2.12` |
| `helm` | `~> 2.6` |

## Usage

Please see `/examples` directory for a list of examples using the module.

## Notable
 `node_count` property must be set in all cases for all the node pools. Setting this value to null could cause an erratic behavior on future updates.

## Known Issues

## Inputs

##Additional Node Pool

| Name | Description |
|------|-------------|
|vm_size|The SKU which should be used for the Virtual Machines used in this Node Pool.|
|os_disk_size_gb|The Agent Operating System disk size in GB|
|enable_autoscaling|Whether to enable auto-scaler|
|vnet_subnet_id|The ID of the Subnet where this Node Pool should exist.|
|pod_subnet_id|The ID of the Subnet where the pods in the Node Pool should exist.|
|max_pods| The maximum number of pods that can run on each agent.|
|node_count|The number of nodes which should exist within this Node Pool. Valid values are between 0 and 1000 (inclusive) for user pools and between 1 and 1000 (inclusive) for system pools.|
|autoscaling_min_nodes|The minimum number of nodes which should exist within this Node Pool. Valid values are between 0 and 1000 and must be less than or equal to max_count|
|autoscaling_max_nodes|The maximum number of nodes which should exist within this Node Pool. Valid values are between 0 and 1000 and must be greater than or equal to min_count.|
|kube_node_labels|A map of Kubernetes labels which should be applied to nodes in this Node Pool.|

##Datadog Integration

| Name | Description |
|------|-------------|
|dd_site|Datadog Site. Default: US3.|
|dd_api_key|API key for Datadog Integration.|
|dd_app_key|APP key for Datadog Integration.|

##WIZ Integration

| Name | Description |
|------|-------------|
|wiz_client_id|Client ID for WIZ integration.|
|wiz_client_secret|Client secret for WIZ integration.|

## Outputs

| Name | Description | Sensitive |
|------|-------------|-----------|
| aks_node_pools_id | Output of the IDs of AKS Cluster Additional Node Pools | No |

## Terraform

### Modules

| Modules |
|---------|
| `datadog-cep` |
| `wiz-cep` |

### Resources

| Resources |
|-----------|
| `azurerm_kubernetes_cluster_node_pool` |

## Owners

| Name |
|---|
| Sanjay Murugan |

## CHANGELOG

***

### Version 3.0.0

* Additional Node Pool Configuration for the Existing Cluster.
* configured Datadog and Wiz integration on AKS cluster