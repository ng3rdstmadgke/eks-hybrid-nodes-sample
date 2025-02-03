resource "local_file" "http_app_cloud" {
  filename = "${var.project_dir}/service/http-app/tmp/ingress-cloud.yaml"
  content = templatefile(
    "${path.module}/ingress.yaml",
    {
      node_type = "cloud"
      subnets = join(",", var.alb_subnet_ids)
      alb_ingress_sg = var.alb_ingress_sg
    }
  )
}

resource "local_file" "http_app_onpremise" {
  filename = "${var.project_dir}/service/http-app/tmp/ingress-onpremise.yaml"
  content = templatefile(
    "${path.module}/ingress.yaml",
    {
      node_type = "onpremise"
      subnets = join(",", var.alb_subnet_ids)
      alb_ingress_sg = var.alb_ingress_sg
    }
  )
}
