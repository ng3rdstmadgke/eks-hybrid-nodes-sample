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

variable key_pair_name {
  type = string
  description = "EC2インスタンスに紐づけるキーペア名"
}

variable ec2_vpc_id {
  type = string
  description = "EC2インスタンスを配置するVPCのID"
}

variable ec2_subnet_id {
  type = string
  description = "EC2インスタンスを配置するサブネットのID"
}

locals {
  cluster_name = data.terraform_remote_state.base.outputs.cluster_name
  project_dir = data.terraform_remote_state.base.outputs.project_dir
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
