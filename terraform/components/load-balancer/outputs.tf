output common_alb_dns_name {
  value = module.common_alb.dns_name
}

output ray_nlb_dns_name {
  value = module.ray_nlb.lb_dns_name
}