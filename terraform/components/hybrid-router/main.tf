terraform {
  required_version = "~> 1.10"

  backend "s3" {
  }

  required_providers {
    // AWS Provider: https://registry.terraform.io/providers/hashicorp/aws/latest/docs
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.82"
    }
  }
}

// AWS Provider: https://registry.terraform.io/providers/hashicorp/aws/latest/docs
provider "aws" {
  region = "ap-northeast-1"
  default_tags {
    tags = {
      PROJECT = "TERRAFORM_TUTORIAL_EKS",
    }
  }
}

/**
 * EKSクラスタネットワークルーター
 */
resource "aws_security_group" "eks_network_router" {
  name        = "${local.cluster_name}-EksNetworkRouterSG"
  description = "${local.cluster_name}-EksNetworkRouterSG"
  vpc_id      = local.eks_network_vpc_id

  ingress {
    description = "Allow All access."
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }


  tags = {
    Name = "${local.cluster_name}-EksNetworkRouterSG"
  }
}


resource "aws_instance" "eks_network_router" {
  ami           = "ami-0a290015b99140cd1"  # ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-20250115
  instance_type = "t3a.small"

  subnet_id = local.eks_network_private_subnet_ids[0]
  enable_primary_ipv6 = false
  key_name = var.key_pair_name
  vpc_security_group_ids = [ aws_security_group.eks_network_router.id ]
  # 送信元/送信先チェックを無効化
  # インスタンスが送受信するパケットの送信元/送信先アドレスをチェックするかどうかを指定します。
  source_dest_check = false

  root_block_device {
    volume_size = 64
    volume_type = "gp3"
    encrypted = true
    delete_on_termination = true
    tags = {
      Name = "${local.cluster_name}-EksNetworkRouter"
    }
  }

  tags = {
    Name = "${local.cluster_name}-EksNetworkRouter"
  }
}

/**
 * リモートネットワークルーター
 */
resource "aws_security_group" "remote_network_router" {
  name        = "${local.cluster_name}-RemoteNetworkRouterSG"
  description = "${local.cluster_name}-RemoteNetworkRouterSG"
  vpc_id      = local.hybrid_nodes_vpc_id

  ingress {
    description = "Allow All access."
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }


  tags = {
    Name = "${local.cluster_name}-RemoteNetworkRouterSG"
  }
}


resource "aws_instance" "remote_network_router" {
  ami           = "ami-0a290015b99140cd1"  # ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-20250115
  instance_type = "t3a.small"

  subnet_id = local.hybrid_nodes_subnet_ids[0]
  enable_primary_ipv6 = false
  key_name = var.key_pair_name
  vpc_security_group_ids = [ aws_security_group.remote_network_router.id ]
  # 送信元/送信先チェックを無効化
  # インスタンスが送受信するパケットの送信元/送信先アドレスをチェックするかどうかを指定します。
  source_dest_check = false

  root_block_device {
    volume_size = 64
    volume_type = "gp3"
    encrypted = true
    delete_on_termination = true
    tags = {
      Name = "${local.cluster_name}-RemoteNetworkRouter"
    }
  }

  tags = {
    Name = "${local.cluster_name}-RemoteNetworkRouter"
  }
}
