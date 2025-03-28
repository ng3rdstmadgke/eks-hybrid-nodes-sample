variable project_name {
  type = string
  description = "プロジェクト名"
}

variable stage {
  type = string
  description = "ステージ名"
}

variable tfstate_bucket {
  type = string
  description = "tfvarsが保存されているバケット"
}

variable tfstate_region {
  type = string
  description = "tfvarsが保存されているバケットのリージョン"
}

locals {
  cluster_name = data.terraform_remote_state.cluster.outputs.cluster_name
  cluster_version = data.terraform_remote_state.cluster.outputs.version
  cluster_security_group_id = data.terraform_remote_state.cluster.outputs.cluster_security_group_id
  cluster_api_endpoint = data.terraform_remote_state.cluster.outputs.api_endpoint
  cluster_certificate = data.terraform_remote_state.cluster.outputs.cluster_certificate
  cluster_subnet_ids = data.terraform_remote_state.cluster.outputs.subnet_ids
  cluster_vpc_id = data.terraform_remote_state.network.outputs.cluster_vpc_id
  hybrid_nodes_remote_network_cidrs = data.terraform_remote_state.network.outputs.hybrid_nodes_remote_network_cidrs
}

// baseコンポーネントのステートを参照
data terraform_remote_state "base" {
  backend = "s3"

  config = {
    region = var.tfstate_region
    bucket = var.tfstate_bucket
    key    = "${var.project_name}/${var.stage}/base/terraform.tfstate"
  }
}

// networkコンポーネントのステートを参照
data "terraform_remote_state" "network" {
  // https://developer.hashicorp.com/terraform/language/state/remote-state-data#argument-reference
  backend = "s3"

  config = {
    // https://developer.hashicorp.com/terraform/language/backend/s3
    region = var.tfstate_region
    bucket = var.tfstate_bucket
    key    = "${var.project_name}/${var.stage}/network/terraform.tfstate"
  }
}

data terraform_remote_state "cluster" {
  backend = "s3"

  config = {
    region = var.tfstate_region
    bucket = var.tfstate_bucket
    key    = "${var.project_name}/${var.stage}/cluster/terraform.tfstate"
  }
}