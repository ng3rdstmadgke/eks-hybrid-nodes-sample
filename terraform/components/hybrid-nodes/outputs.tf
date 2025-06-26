output "key_pair_name" {
  value = var.key_pair_name
}

output "hybrid_node_ips" {
  value = [for node in module.hybrid_node : node.instance.ip_address ]
}