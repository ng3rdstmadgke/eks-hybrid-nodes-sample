variable "short_project_name" {
  type        = string
  description = "プロジェクト名 (短縮)"
}

variable "stage" {
  type        = string
  description = "The stage name"
}

variable "cluster_name" {
  type        = string
  description = "The name of the cluster."
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "target_ips" {
  type = list(string)
}

variable "port_map" {
  type = map(
    object({lb_port = number, node_port = number})
  )
}