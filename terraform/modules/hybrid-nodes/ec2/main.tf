resource "aws_instance" "hybrid_node" {
  ami           = var.ami_id
  instance_type = var.instance_type

  subnet_id = var.subnet_id
  enable_primary_ipv6 = false
  key_name = var.key_pair_name
  vpc_security_group_ids = var.security_group_ids
  # 送信元/送信先チェックを無効化
  # インスタンスが送受信するパケットの送信元/送信先アドレスをチェックするかどうかを指定します。
  source_dest_check = false

  root_block_device {
    volume_size = 128
    volume_type = "gp3"
    encrypted = true
    delete_on_termination = true
    tags = {
      Name = "${var.cluster_name}-${var.name}"
    }
  }

  tags = {
    Name = "${var.cluster_name}-${var.name}"
  }
}
