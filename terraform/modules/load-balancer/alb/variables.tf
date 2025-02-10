variable alb_name {
  type = string
  description = "ALB名"
}

variable cluster_name {
  type = string
  description = "クラスタ名"
}

variable vpc_id {
  type = string
  description = "LBを配置するVPC ID"
}

variable subnet_ids {
  type = list(string)
  description = "LBを配置するサブネットIDのリスト"
}

variable target_ips {
  type = list(string)
  description = "ALBのターゲットとして登録するIPアドレスとポート"
}

variable target_port {
  type = number
  description = "ALBのターゲットとして登録するポート"
}