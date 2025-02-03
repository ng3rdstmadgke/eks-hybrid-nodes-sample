variable project_dir {
  type = string
  description = "プロジェクトディレクトリの絶対パス"
}

variable remote_pod_network_cidrs {
  type = list(string)
  description = "リモートポッドネットワークCIDR"
}