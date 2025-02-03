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
 * ハイブリッドノードロール
 */
module "eks_hybrid_node_role" {
  source  = "terraform-aws-modules/eks/aws//modules/hybrid-node-role"
  version = "~> 20.31"
  name = "${local.cluster_name}-HybridNode"
}

/**
 * ハイブリッドノードインスタンス
 */
resource "aws_security_group" "hybrid_node" {
  name        = "${local.cluster_name}-HybridNodeSG"
  description = "Allow HTTP, HTTPS access."
  vpc_id      = local.vpc_id

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
    Name = "${local.cluster_name}-HybridNodeSG"
  }
}


resource "aws_instance" "hybrid_node_01" {
  ami           = "ami-06c6f3fa7959e5fdd"  # ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*
  instance_type = "t3a.large"

  subnet_id = local.private_subnet_ids[0]
  enable_primary_ipv6 = false
  key_name = var.key_pair_name
  vpc_security_group_ids = [ aws_security_group.hybrid_node.id ]

  root_block_device {
    volume_size = 128
    volume_type = "gp3"
    encrypted = true
    delete_on_termination = true
    tags = {
      Name = "${local.cluster_name}-HybridNode"
    }
  }

  tags = {
    Name = "${local.cluster_name}-HybridNode"
  }
}
