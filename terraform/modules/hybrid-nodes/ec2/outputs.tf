output instance {
  value = {
    hostname = "${var.cluster_name}-${var.name}"
    ip_address = aws_instance.hybrid_node.private_ip
  }
}