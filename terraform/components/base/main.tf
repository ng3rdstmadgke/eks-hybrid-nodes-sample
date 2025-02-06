terraform {
  required_version = "~> 1.10"

  // tfstateファイルをs3で管理する: https://developer.hashicorp.com/terraform/language/settings/backends/s3
  backend "s3" {
    // NOTE: tfstateの保存先情報は terraform init 時に変数ファイル(terraform/components/tfvars/dev.backend.tfvars) で指定します。
  }

  required_providers {
    // AWS Provider: https://registry.terraform.io/providers/hashicorp/aws/latest/docs
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.82.2"
    }
  }
}

data "aws_subnet" "hybrid_node_subnets" {
  for_each = toset(var.hybrid_nodes_subnet_ids)
  id = each.value
}

output "cluster_name" {
  value = "${var.project_name}-${var.stage}"
}

output "project_dir" {
  value = abspath("${path.module}/../../..")
}

output "hybrid_nodes_vpc_id" {
  value = var.hybrid_nodes_vpc_id
}

output "hybrid_nodes_subnet_ids" {
  value = var.hybrid_nodes_subnet_ids
}

output "hybrid_nodes_remote_network_cidrs" {
  value = [for subnet in data.aws_subnet.hybrid_node_subnets : subnet.cidr_block]
}

output "hybrid_nodes_remote_pod_network_cidrs" {
  value = var.hybrid_nodes_remote_pod_network_cidrs
}
