variable "project_name" {
  type        = string
  description = "プロジェクト名"
}

variable "short_project_name" {
  type        = string
  description = "プロジェクト名 (短縮)"
}

variable "stage" {
  type        = string
  description = "ステージ名"
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

variable "certificate_arn" {
  type        = string
  description = "ALBのSSL証明書ARN"
}

variable "targets" {
  type = map(
    object({
      ips               = list(string)
      port              = number
      domain         = string
      health_check_path = string
    })
  )
}

locals {
  alb_name = "common"
}