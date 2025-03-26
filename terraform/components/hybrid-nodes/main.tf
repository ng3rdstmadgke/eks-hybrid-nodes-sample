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
 * ハイブリッドノードの共通リソース
 */
module "common" {
  source = "../../modules/hybrid-nodes/common"
  cluster_name = local.cluster_name
  onpremise_vpc_id = local.onpremise_vpc_id
}

/**
 * ハイブリッドノードインスタンス
 */

module "hybrid_node" {
  for_each = local.hybrid_nodes
  source = "../../modules/hybrid-nodes/ec2"
  cluster_name = local.cluster_name
  name = each.value.name
  ami_id = each.value.ami_id
  instance_type = each.value.instance_type
  subnet_id = each.value.subnet_id
  key_pair_name = var.key_pair_name
  security_group_ids = [ module.common.hybrid_node_sg.id ]
}

/**
 * ssh_configファイル
 */
resource "local_file" "ssh_config" {
  filename = "${local.project_dir}/tmp/config"
  file_permission = "0600"
  directory_permission = "0755"
  content = templatefile(
    "${path.module}/resources/config",
    {
      hybrid_nodes = module.hybrid_node
      key_pair_name = var.key_pair_name
    }
  )
}

/**
 * ansible用ファイル
 */
resource "local_file" "inventory" {
  filename = "${local.project_dir}/ansible/inventory_${var.stage}.yml"
  directory_permission = "0755"
  file_permission = "0644"
  content = templatefile(
    "${path.module}/resources/inventory.yml",
    {
      stage = var.stage
      hybrid_nodes = module.hybrid_node
      cluster_name = local.cluster_name
      cluster_version = local.cluster_version
      cluster_api_endpoint = local.cluster_api_endpoint
      cluster_certificate = local.cluster_certificate
      key_pair_name = var.key_pair_name
    }
  )
}

resource "aws_ssm_activation" "hybrid_node" {
  for_each = module.hybrid_node
  name = each.value.instance.hostname
  description = "${each.value.instance.hostname} activation"
  iam_role = module.common.hybrid_node_role.name
  registration_limit = "1"
  tags = {
    Name = each.value.instance.hostname
    EKSClusterARN = local.cluster_arn
  }
}

resource "local_file" "host_vars" {
  for_each = module.hybrid_node
  filename = "${local.project_dir}/ansible/host_vars/${each.value.instance.hostname}.yml"
  directory_permission = "0755"
  file_permission = "0644"
  content = templatefile(
    "${path.module}/resources/host_vars.yml",
    {
      activation_id = aws_ssm_activation.hybrid_node[each.key].id
      activation_code = aws_ssm_activation.hybrid_node[each.key].activation_code
    }
  )
}