/**
 * ALB用セキュリティグループ
 * aws_security_group: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
 */
resource "aws_security_group" "alb_sg" {
  name   = "${var.cluster_name}-ALB-${local.alb_name}"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.cluster_name}-ALB-${local.alb_name}"
  }
}

/**
 * ALB
 * aws_alb: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb
 */
resource "aws_lb" "this" {
  name               = substr("${var.short_project_name}-${var.stage}-${local.alb_name}", 0, 32)
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.subnet_ids
  ip_address_type    = "ipv4"
  idle_timeout       = 60
  internal           = false
  tags = {
    Name = "${var.short_project_name}-${var.stage}-${local.alb_name}"
  }
}

/**
 * ALBターゲットグループ
 * aws_lb_target_group: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group
 */
resource "aws_lb_target_group" "this" {
  for_each = var.targets

  name        = substr("${var.short_project_name}-${var.stage}-${local.alb_name}-${each.key}", 0, 32)
  port        = "80"
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    path                = each.value.health_check_path
    protocol            = "HTTP"
    matcher             = "200"
  }

  tags = {
    Name = "${var.short_project_name}-${var.stage}-${local.alb_name}-${each.key}"
  }
}

locals {
  // ターゲットIPとターゲットポートで二重ループしたいのでportとipの組み合わせを一次配列にする
  tg_attachments = flatten([
    for k, v in var.targets : [
      for ip in v.ips : {
        key         = "${k}-${ip}"
        target_key  = k
        ip          = ip
        port        = v.port
      }
    ]
  ])
}

resource "aws_lb_target_group_attachment" "this" {
  for_each = {
    for e in local.tg_attachments : e.key => e
  }

  target_group_arn  = aws_lb_target_group.this[each.value.target_key].arn
  target_id         = each.value.ip
  port              = each.value.port
  availability_zone = "all"
}

/**
 * ALBのリスナー (HTTP を利用する場合)
 * aws_lb_listener: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener
 */
resource "aws_lb_listener" "http" {
  count             = 1
  load_balancer_arn = aws_lb.this.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

// aws_lb_listener_rule: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule
# resource "aws_lb_listener_rule" "http_hostname" {
#   for_each = var.targets
#   listener_arn = aws_lb_listener.http.arn
# 
#   action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.this[each.key].arn
#   }
# 
#   condition {
#     host_header {
#       values = [each.value.domain]
#     }
#   }
# }

# TODO: HTTPS対応
/**
 * ALBのリスナー (HTTPS)
 * aws_lb_listener: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener
 */
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.this.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      status_code = 404
    }
  }
}

// aws_lb_listener_rule: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule
resource "aws_lb_listener_rule" "https_hostname" {
  for_each = var.targets
  listener_arn = aws_lb_listener.https.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[each.key].arn
  }

  condition {
    host_header {
      values = [each.value.domain]
    }
  }
}