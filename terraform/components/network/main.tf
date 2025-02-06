terraform {
  required_version = "~> 1.10"

  backend "s3" {
  }

  required_providers {
    // AWS Provider: https://registry.terraform.io/providers/hashicorp/aws/latest/docs
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.82.2"
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
 * VPC作成
 *
 * terraform-aws-modules/vpc/aws | Terraform
 * https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest
 */
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> 5.17.0"

  name = "${local.cluster_name}-vpc"
  cidr = var.vpc_cidr

  azs             = ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"]
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway = true
  single_nat_gateway = true
  enable_vpn_gateway = false

  // パブリックサブネットを外部LB用に利用することをKubernetesとALBが認識できるようにするためのタグ
  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }
  // プライベートネットを内部LB用に利用することをKubernetesとALBが認識できるようにするためのタグ
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }
}


data "aws_caller_identity" "current" {}

resource "aws_vpc_peering_connection" "this" {
  peer_owner_id = data.aws_caller_identity.current.account_id
  vpc_id        = var.requester_vpc_id
  peer_vpc_id   = module.vpc.vpc_id
  auto_accept = true

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }

  tags = {
    Name = "${local.cluster_name}"
  }
}

/**
 * ハイブリッドノードルーター
 */
resource "aws_security_group" "hybrid_node_router" {
  name        = "${local.cluster_name}-RouterSG"
  description = "${local.cluster_name}-RouterSG"
  vpc_id      = module.vpc.vpc_id

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
    Name = "${local.cluster_name}-RouterSG"
  }
}


resource "aws_instance" "hybrid_node_router" {
  ami           = "ami-0a290015b99140cd1"  # ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-20250115
  instance_type = "t3a.small"

  subnet_id = module.vpc.private_subnets[0]
  enable_primary_ipv6 = false
  key_name = var.key_pair_name
  vpc_security_group_ids = [ aws_security_group.hybrid_node_router.id ]
  # 送信元/送信先チェックを無効化
  # インスタンスが送受信するパケットの送信元/送信先アドレスをチェックするかどうかを指定します。
  source_dest_check = false

  root_block_device {
    volume_size = 64
    volume_type = "gp3"
    encrypted = true
    delete_on_termination = true
    tags = {
      Name = "${local.cluster_name}-Router"
    }
  }

  tags = {
    Name = "${local.cluster_name}-Router"
  }
}