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

locals {
  cluster_name = data.terraform_remote_state.cluster.outputs.cluster_name
  cluster_version = data.terraform_remote_state.cluster.outputs.version
  cluster_api_endpoint = data.terraform_remote_state.cluster.outputs.api_endpoint
  cluster_certificate = data.terraform_remote_state.cluster.outputs.cluster_certificate
  cluster_arn = data.terraform_remote_state.cluster.outputs.cluster_arn
  project_dir = data.terraform_remote_state.base.outputs.project_dir
  onpremise_vpc_id = data.terraform_remote_state.network.outputs.onpremise_vpc_id
  onpremise_private_subnet_ids = data.terraform_remote_state.network.outputs.onpremise_private_subnet_ids
  hybrid_nodes = {
    "node01" = {
      "name" = "node01"
      "ami_id" = "ami-026c39f4021df9abe"  # ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-20250305
      "instance_type" = "g4dn.xlarge"
      "subnet_id" = local.onpremise_private_subnet_ids[0]
    }
    "node02" = {
      "name" = "node02"
      "ami_id" = "ami-026c39f4021df9abe"  # ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-20250305
      "instance_type" = "g4dn.xlarge"
      "subnet_id" = local.onpremise_private_subnet_ids[1]
    }
    "node03" = {
      "name" = "node03"
      "ami_id" = "ami-026c39f4021df9abe"  # ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-20250305
      "instance_type" = "t3a.large"
      "subnet_id" = local.onpremise_private_subnet_ids[2]
    }
  }
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
data terraform_remote_state "network" {
  backend = "s3"

  config = {
    region = var.tfstate_region
    bucket = var.tfstate_bucket
    key    = "${var.project_name}/${var.stage}/network/terraform.tfstate"
  }
}

// networkコンポーネントのステートを参照
data terraform_remote_state "cluster" {
  backend = "s3"

  config = {
    region = var.tfstate_region
    bucket = var.tfstate_bucket
    key    = "${var.project_name}/${var.stage}/cluster/terraform.tfstate"
  }
}
