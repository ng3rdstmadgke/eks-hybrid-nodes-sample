ray_nlb_port_map = {
  py312-client    = {lb_port = 10001, node_port = 30898},
  py312-dashboard = {lb_port = 10002, node_port = 32175},
}

alb_targets = {
  ray-py312-dashboard = {
    ips               = [
      "xxx.xxx.xxx.xxx",  // hybrid node IP
      "xxx.xxx.xxx.xxx",  // hybrid node IP
      "xxx.xxx.xxx.xxx",  // hybrid node IP
    ]
    port              = 32169,
    subdomain         = "ray-py312-dashboard",
    health_check_path = "/api/version",
  },
  ollama = {
    ips               = [
      "xxx.xxx.xxx.xxx",  // hybrid node IP
      "xxx.xxx.xxx.xxx",  // hybrid node IP
      "xxx.xxx.xxx.xxx",  // hybrid node IP
    ]
    port              = 30001,
    subdomain         = "ollama",
    health_check_path = "/api/version",
  },
}
