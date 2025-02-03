variable cluster_name {
  type = string
  description = "EKSクラスタ名"
}
variable subnet_ids {
  type = list(string)
  description = "EKSクラスタを作成するサブネットID"
}
variable access_entries {
  type = list(string)
  description = "EKSのIAMアクセスエントリに登録するIAMユーザまたはIAMロールのARN"
}
variable vpc_id {
  type = string
  description = "EKSクラスタを作成するVPC ID"
}
variable hybrid_network_cidrs {
  type = list(string)
  description = "Hybrid Nodesを利用する場合のCIDR"
}

data "aws_caller_identity" "self" { }

locals {
  account_id = data.aws_caller_identity.self.account_id
}