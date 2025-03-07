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


module "app_alb" {
  source = "../../modules/load-balancer/alb"
  alb_name = "HttpApp"
  cluster_name = local.cluster_name
  vpc_id = local.cluster_vpc_id
  subnet_ids = local.cluster_public_subnet_ids
  target_ips = local.hybrid_node_ips
  target_port = 30080
}
