locals {
  subnet_id_array = split("/", var.default_node_pool.subnet_id)
}