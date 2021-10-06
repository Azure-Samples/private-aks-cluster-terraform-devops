output "id" {
  description = "Specifies the resource id of the node pool"
  value       = azurerm_kubernetes_cluster_node_pool.node_pool.id
}