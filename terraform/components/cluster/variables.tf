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

variable access_entries {
  type = list(string)
  description = "EKSのIAMアクセスエントリに登録するIAMユーザまたはIAMロールのARN"
}

variable hybrid_network_cidrs {
  type = list(string)
  description = "Hybrid Nodesを利用する場合のCIDR"
}

locals {
  cluster_name = data.terraform_remote_state.base.outputs.cluster_name
  private_subnet_ids = data.terraform_remote_state.network.outputs.private_subnet_ids
  vpc_id = data.terraform_remote_state.network.outputs.vpc_id
  hybrid_nodes_remote_network_cidrs = data.terraform_remote_state.base.outputs.hybrid_nodes_remote_network_cidrs
  hybrid_nodes_remote_pod_network_cidrs = data.terraform_remote_state.base.outputs.hybrid_nodes_remote_pod_network_cidrs
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