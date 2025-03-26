variable cluster_name {
  type = string
  description = "EKSクラスタ名"
}

variable name {
  type = string
  description = "Nameタグ"
}

variable ami_id {
  type = string
  description = "AMI ID"
}

variable instance_type {
  type = string
  description = "インスタンスタイプ"
}

variable subnet_id {
  type = string
  description = "サブネットID"
}

variable key_pair_name {
  type = string
  description = "EC2インスタンスに紐づけるキーペア名"
}

variable security_group_ids {
  type = list(string)
  description = "セキュリティグループID"
}
