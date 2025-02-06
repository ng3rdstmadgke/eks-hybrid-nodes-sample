output "remote_network_router_ip" {
  value = aws_instance.remote_network_router.private_ip
}

output "eks_network_router_ip" {
  value = aws_instance.eks_network_router.private_ip
}