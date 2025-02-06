variable project_name {
  type = string
  description = "プロジェクト名"
}

variable stage {
  type = string
  description = "ステージ名"
}

variable tfstate_region {
  type = string
  description = "tfstateが保存されているリージョン"
}

variable tfstate_bucket {
  type = string
  description = "tfstateが保存されているS3バケット"
}

variable hybrid_nodes_vpc_id {
  type = string
  description = "ハイブリッドノードのVPC ID"
}

variable hybrid_nodes_subnet_ids {
  type = list(string)
  description = "ハイブリッドノードのサブネットID"
}

variable hybrid_nodes_remote_pod_network_cidrs {
  type = list(string)
  description = "ハイブリッドノードのPod CIDR"
}