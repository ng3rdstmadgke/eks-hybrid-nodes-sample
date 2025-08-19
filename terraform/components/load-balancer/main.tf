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

module "ray_nlb" {
  source             = "../../modules/load-balancer/ray"
  short_project_name = local.short_project_name
  stage              = var.stage
  cluster_name       = local.cluster_name
  vpc_id             = local.cluster_vpc_id
  subnet_ids         = local.cluster_public_subnet_ids
  target_ips         = local.hybrid_node_ips
  port_map           = var.ray_nlb_port_map
}


module "common_alb" {
  source             = "../../modules/load-balancer/alb"
  project_name       = var.project_name
  short_project_name = local.short_project_name
  stage              = var.stage
  cluster_name       = local.cluster_name
  vpc_id             = local.vpc_id
  subnet_ids         = local.subnet_ids
  domain             = var.alb_domain
  targets            = var.alb_targets
}