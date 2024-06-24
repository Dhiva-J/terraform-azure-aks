terraform {
  required_version = ">= 1.3.9"
  required_providers {
    azurerm    = "~> 3.0"
    azuread    = "~> 2.0"
    kubernetes = "~> 2.12"
    helm       = "~> 2.6"
  }
}