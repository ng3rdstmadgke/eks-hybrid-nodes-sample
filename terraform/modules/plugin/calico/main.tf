resource "local_file" "albc_values" {
  filename = "${var.project_dir}/plugin/calico/tmp/values.yaml"
  content = templatefile(
    "${path.module}/values.yaml",
    {
      remote_pod_network_cidrs = var.remote_pod_network_cidrs
    }
  )
}
