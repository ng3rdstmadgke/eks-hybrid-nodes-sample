/**
 * ALB用セキュリティグループ
 * aws_security_group: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
 */
resource "aws_security_group" "nlb_ray" {
  name   = "${var.cluster_name}-NLB-Ray"
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.cluster_name}-NLB-Ray"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ray" {
  for_each = var.port_map
  security_group_id = aws_security_group.nlb_ray.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = each.value.lb_port
  to_port           = each.value.lb_port
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.nlb_ray.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

/**
 * NLB
 * aws_lb: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb
 */
resource "aws_lb" "ray_cluster_nlb" {
  name               = substr("${var.short_project_name}-${var.stage}-Ray", 0, 32)
  #internal           = false
  load_balancer_type = "network"
  ip_address_type    = "ipv4"
  subnets            = var.subnet_ids
  security_groups    = [aws_security_group.nlb_ray.id]
  idle_timeout       = 60
  tags = {
    Name = "${var.short_project_name}-${var.stage}-Ray"
  }
}

/**
 * NLBターゲットグループ
 * aws_lb_target_group: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group
 */
resource "aws_lb_target_group" "ray_cluster_tg" {
  for_each = var.port_map

  name        = substr("${var.short_project_name}-${var.stage}-Ray-${each.key}", 0, 32)
  port        = each.value.lb_port
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    protocol = "TCP"
    port     = "traffic-port"
  }

  tags = {
    Name = "${var.short_project_name}-${var.stage}-Ray-${each.key}"
  }
}

locals {
  // ターゲットIPとターゲットポートで二重ループしたいのでportとipの組み合わせを一次配列にする
  tg_attachments = flatten([
    for port_key, port_val in var.port_map : [
      for ip in var.target_ips : {
        key         = "${port_key}-${ip}"
        port_key    = port_key
        target_ip   = ip
        lb_port     = port_val.lb_port
        node_port = port_val.node_port
      }
    ]
  ])
}

resource "aws_lb_target_group_attachment" "ray_cluster_tg_attachment" {
  for_each = {
    for entry in local.tg_attachments : entry.key => entry
  }

  target_group_arn = aws_lb_target_group.ray_cluster_tg[each.value.port_key].arn
  target_id        = each.value.target_ip
  port             = each.value.node_port
  availability_zone = "all"
}

/**
 * NLBのリスナー
 * aws_lb_listener: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener
 */
resource "aws_lb_listener" "ray_cluster_listener" {
  for_each = var.port_map

  load_balancer_arn = aws_lb.ray_cluster_nlb.arn
  port              = each.value.lb_port
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ray_cluster_tg[each.key].arn
  }
}