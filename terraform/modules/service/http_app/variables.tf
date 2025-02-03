variable project_dir {
  type = string
  description = "プロジェクトディレクトリの絶対パス"
}

variable alb_subnet_ids {
  type = list(string)
  description = "ALBが配置されるサブネットID"
}

variable alb_ingress_sg {
  type = string
  description = "ALBのセキュリティグループID"
}