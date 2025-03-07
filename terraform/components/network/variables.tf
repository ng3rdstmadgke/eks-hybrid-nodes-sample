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

variable "transit_gateway_id" {
  type = string
  description = "Transit Gateway ID"
}

locals {
  cluster_name = data.terraform_remote_state.base.outputs.cluster_name
  cluster_vpc_cidr = "10.80.0.0/16"
  cluster_private_subnets = [
    "10.80.1.0/24",
    "10.80.2.0/24",
    "10.80.3.0/24",
  ]
  cluster_public_subnets = [
    "10.80.101.0/24",
    "10.80.102.0/24",
    "10.80.103.0/24",
  ]
  onpremise_vpc_cidr = "10.90.0.0/16"
  onpremise_private_subnets = [
    "10.90.1.0/24",
    "10.90.2.0/24",
    "10.90.3.0/24",
  ]
  onpremise_public_subnets = [
    "10.90.101.0/24",
    "10.90.102.0/24",
    "10.90.103.0/24",
  ]
}

data terraform_remote_state "base" {
  backend = "s3"

  config = {
    region = var.tfstate_region
    bucket = var.tfstate_bucket
    key    = "${var.project_name}/${var.stage}/base/terraform.tfstate"
  }
}