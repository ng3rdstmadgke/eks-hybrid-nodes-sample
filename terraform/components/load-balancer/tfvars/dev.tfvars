ray_nlb_port_map = {
  py312-client    = {lb_port = 10001, node_port = 30919},
}

alb_certificate_arn = "arn:aws:acm:ap-northeast-1:xxxxxxxxxxxx:certificate/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

alb_targets = {
  ray-py312-dashboard = {
    ips               = [
      "10.90.1.52",
      "10.90.2.161",
      "10.90.3.111",
    ]
    port              = 31373,
    domain            = "ray-py312.hnb-dev.baseport.net",
    health_check_path = "/api/version",
  },
  ollama = {
    ips               = [
      "10.90.1.52",
      "10.90.2.161",
      "10.90.3.111",
    ]
    port              = 30001,
    domain            = "ollama.hnb-dev.baseport.net",
    health_check_path = "/api/version",
  },
}
