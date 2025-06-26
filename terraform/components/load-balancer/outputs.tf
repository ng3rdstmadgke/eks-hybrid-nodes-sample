output app_alb_dns_name {
  value = module.app_alb.dns_name
}

output ray_cluster_nlb_dns_name {
  value = module.ray_nlb.lb_dns_name
}