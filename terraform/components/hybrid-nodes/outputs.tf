output hybrid_node_01_ip {
  value = aws_instance.hybrid_node_01.private_ip
}

output hybrid_node_02_ip {
  value = aws_instance.hybrid_node_02.private_ip
}

output hybrid_node_ips {
  value = [
    aws_instance.hybrid_node_01.private_ip,
    aws_instance.hybrid_node_02.private_ip,
  ]
}

output hybrid_node_role {
  value = module.eks_hybrid_node_role.name
}