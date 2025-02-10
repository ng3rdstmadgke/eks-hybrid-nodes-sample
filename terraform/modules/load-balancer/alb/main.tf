/**
 * ALB用セキュリティグループ
 * aws_security_group: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
 */
resource "aws_security_group" "alb_sg" {
  name   = "${var.cluster_name}-${var.alb_name}"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
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
    Name = "${var.cluster_name}-${var.alb_name}"
  }
}

/**
 * ALB
 * aws_alb: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb
 */
resource "aws_lb" "this" {
  name               = "${var.cluster_name}-${var.alb_name}"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.subnet_ids
  ip_address_type    = "ipv4"
  idle_timeout       = 60
  internal           = false
  tags = {
    Name = "${var.cluster_name}-${var.alb_name}"
  }
}

/**
 * ALBターゲットグループ
 * aws_lb_target_group: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group
 */
resource "aws_lb_target_group" "this" {
  name        = "${var.cluster_name}-${var.alb_name}"
  port        = "80"
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
  }

  tags = {
    Name = "${var.cluster_name}-${var.alb_name}"
  }
}

resource "aws_lb_target_group_attachment" "this" {
  for_each = toset(var.target_ips)
  target_group_arn = aws_lb_target_group.this.arn
  target_id        = each.key
  availability_zone = "all"
  port             = var.target_port
}

/**
 * ALBのリスナー (HTTP を利用する場合)
 * aws_lb_listener: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener
 */
resource "aws_lb_listener" "this" {
  count             = 1
  load_balancer_arn = aws_lb.this.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "forward"
    forward {
      target_group {
        arn    = aws_lb_target_group.this.arn
        weight = 1
      }
    }
  }
}
