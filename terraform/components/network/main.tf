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
 * EKSクラスタを配置するVPC
 *
 * terraform-aws-modules/vpc/aws | Terraform
 * https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest
 */
module "cluster_vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> 5.17.0"

  name = "${local.cluster_name}-cluster-vpc"
  cidr = local.cluster_vpc_cidr

  azs             = ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"]
  private_subnets = local.cluster_private_subnets
  public_subnets  = local.cluster_public_subnets

  enable_nat_gateway = true
  single_nat_gateway = true
  enable_vpn_gateway = false
}

resource "aws_ec2_transit_gateway_vpc_attachment" "cluster_vpc" {
  subnet_ids         = module.cluster_vpc.private_subnets
  transit_gateway_id = var.transit_gateway_id
  vpc_id             = module.cluster_vpc.vpc_id
  dns_support = "enable"
  ipv6_support = "disable"
  security_group_referencing_support = "enable"
  appliance_mode_support = "disable"
  transit_gateway_default_route_table_association = true
  tags = {
    Name = "${local.cluster_name}-cluster-vpc-attachment"
  }
}

/**
 * オンプレノードを配置するVPC
 *
 * terraform-aws-modules/vpc/aws | Terraform
 * https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest
 */
module "onpremise_vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> 5.17.0"

  name = "${local.cluster_name}-onpremise-vpc"
  cidr = local.cluster_vpc_cidr

  azs             = ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"]
  private_subnets = local.cluster_private_subnets
  public_subnets  = local.cluster_public_subnets

  enable_nat_gateway = true
  single_nat_gateway = true
  enable_vpn_gateway = false
}

resource "aws_ec2_transit_gateway_vpc_attachment" "onpremise_vpc" {
  subnet_ids         = module.onpremise_vpc.private_subnets
  transit_gateway_id = var.transit_gateway_id
  vpc_id             = module.onpremise_vpc.vpc_id
  dns_support = "enable"
  ipv6_support = "disable"
  security_group_referencing_support = "enable"
  appliance_mode_support = "disable"
  transit_gateway_default_route_table_association = true
  tags = {
    Name = "${local.cluster_name}-onpremise-vpc-attachment"
  }
}