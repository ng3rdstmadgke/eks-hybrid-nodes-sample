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

variable "ray_nlb_port_map" {
  type = map(
    object({
      lb_port = number,    # NLBが受けるポート
      node_port = number,  # ターゲットが受けるポート(RayClusterのヘッドノードのNodePort)
    })
  )
  description = "Ray Cluster用のNLBのポートマッピング"
}

variable "alb_domain" {
  type        = string
  description = "ALBのドメイン名"
}

variable "alb_targets" {
  type = map(
    object({
      ips = list(string),  # ALBのターゲットIP
      port = number        # ALBのターゲットポート
      subdomain = string   # ルーティング用のサブドメイン
      health_check_path = string  # ヘルスチェックパス
    })
  )
  description = "ALBのターゲット情報"
}

locals {
  short_project_name = "hns"
  cluster_name = data.terraform_remote_state.cluster.outputs.cluster_name
  cluster_vpc_id = data.terraform_remote_state.network.outputs.cluster_vpc_id
  cluster_public_subnet_ids = data.terraform_remote_state.network.outputs.cluster_public_subnet_ids
  hybrid_node_ips = data.terraform_remote_state.hybrid_nodes.outputs.hybrid_node_ips
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

// clusterコンポーネントのステートを参照
data "terraform_remote_state" "cluster" {
  // https://developer.hashicorp.com/terraform/language/state/remote-state-data#argument-reference
  backend = "s3"
  config = {
    // https://developer.hashicorp.com/terraform/language/backend/s3
    region = var.tfstate_region
    bucket = var.tfstate_bucket
    key    = "${var.project_name}/${var.stage}/cluster/terraform.tfstate"
  }
}

// hybrid-nodesコンポーネントのステートを参照
data "terraform_remote_state" "hybrid_nodes" {
  // https://developer.hashicorp.com/terraform/language/state/remote-state-data#argument-reference
  backend = "s3"
  config = {
    // https://developer.hashicorp.com/terraform/language/backend/s3
    region = var.tfstate_region
    bucket = var.tfstate_bucket
    key    = "${var.project_name}/${var.stage}/hybrid-nodes/terraform.tfstate"
  }
}