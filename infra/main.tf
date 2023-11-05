/**
 * # Favicon Terraform Module
 *
 * We can autogenerate a readme with the [terraform-docs](https://terraform-docs.io/) tool.  Use this command to generate:
 *
 * ```bash
 * terraform-docs markdown table --anchor=false . > README.md
 * ```
 *
 * Edit the header comment in `main.tf` for any changes. 
 *
 * ## Summary
 *
 * This module will provision all the infrastructure necessary to run the favicon service.   This is comprised of the following:
 * - ALB Load Balancer 
 * - Target group.
 * - AutoScaling Group
 * - S3 Bucket to hold deployment object
 * - Redis Database
 */

#################
# Various Locals
#################

locals {
  final_name = "${var.env_name}-${var.stack_name}"

  final_ami = coalesce(
    var.ami_id,            # Explictly specified AMI takes precedence
    data.aws_ami.ubuntu.id # Fallback to latest Ubuntu 20.04
  )
}

########################
# Load balancer config
########################

data "aws_vpc" "vpc_data" {
  id = var.vpc_id
}

resource "aws_lb_target_group" "this" {
  name     = coalesce(var.tg_name_override, local.final_name) #using name due to 6 character limit on name_prefix...
  port     = var.target_group_port
  protocol = var.target_group_protocol
  vpc_id   = var.vpc_id

  health_check {
    path     = var.target_group_health_check_path
    port     = var.target_group_port
    protocol = var.target_group_protocol

    interval            = var.target_group_health_check_interval
    healthy_threshold   = var.target_group_healthy_threshold
    unhealthy_threshold = var.target_group_unhealthy_threshold
  }

  stickiness {
    type            = "lb_cookie"
    enabled         = var.enable_tg_stickiness
    cookie_duration = var.tg_sticky_duration
  }
}

resource "aws_lb" "this" {
  name               = coalesce(var.lb_name_override, local.final_name)
  internal           = var.internal_load_balancer
  load_balancer_type = "application"

  security_groups = coalescelist(var.lb_security_group_list, aws_security_group.internal_sg.*.id)
  subnets         = var.subnets

  idle_timeout = var.lb_idle_timeout
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.this.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_security_policy
  certificate_arn   = var.ssl_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = "80"
  protocol          = "HTTP"

  dynamic "default_action" {
    for_each = var.redirect_http ? [] : [1]
    content {
      type             = "forward"
      target_group_arn = aws_lb_target_group.this.arn
    }
  }

  dynamic "default_action" {
    for_each = var.redirect_http ? [1] : []
    content {
      type = "redirect"

      redirect {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  }
}

resource "aws_security_group" "internal_sg" {
  count = length(var.lb_security_group_list) == 0 ? 1 : 0

  name_prefix = "${local.final_name}-lb-"
  description = "Allows traffic for ${var.env_name}-${var.stack_name} Load Balancer"
  vpc_id      = var.vpc_id

}

resource "aws_security_group_rule" "lb_allow_https" {
  count = length(var.lb_security_group_list) == 0 ? 1 : 0

  security_group_id = aws_security_group.internal_sg[0].id

  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  description = "Allow HTTPS access"

  cidr_blocks = var.internal_trusted_networks
}

resource "aws_security_group_rule" "lb_allow_http" {
  count             = length(var.lb_security_group_list) == 0 ? 1 : 0
  security_group_id = aws_security_group.internal_sg[0].id

  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  description = "Http to Https redirect"

  cidr_blocks = var.internal_trusted_networks
}

resource "aws_security_group_rule" "lb_allow_all_egress" {
  count             = length(var.lb_security_group_list) == 0 ? 1 : 0
  security_group_id = aws_security_group.internal_sg[0].id

  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  description = "Allow all egress"
  cidr_blocks = ["0.0.0.0/0"]
}

####################
# Autoscaling Group
####################

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_launch_template" "this" {
  name_prefix            = "${local.final_name}-"
  image_id               = local.final_ami
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.this.id]
  key_name               = var.ec2_key_pair

  user_data = base64encode(file("${path.module}/bootstrap.sh"))

  iam_instance_profile {
    name = aws_iam_instance_profile.this.name
  }

  tags = var.custom_lt_tags
}

resource "aws_iam_role" "this" {
  name_prefix = "${local.final_name}-"
  description = "IAM Role to allow AWS Permissions for ${local.final_name} EC2 Instance."

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "this" {
  for_each = var.managed_policy_arns

  role       = aws_iam_role.this.name
  policy_arn = each.value
}

resource "aws_iam_instance_profile" "this" {
  name = aws_iam_role.this.name
  role = aws_iam_role.this.name
}

resource "aws_autoscaling_group" "this" {
  name_prefix      = "${local.final_name}-"
  desired_capacity = var.asg_desired
  max_size         = var.asg_max
  min_size         = var.asg_min

  vpc_zone_identifier       = var.subnets
  health_check_type         = var.health_check_type
  health_check_grace_period = var.health_check_grace_period
  target_group_arns         = var.target_group_arn_list

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = local.final_name
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = var.asg_tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}

resource "aws_security_group" "this" {
  name_prefix = "${local.final_name}-"
  description = "Allows internal traffic to EC2 instance"
  vpc_id      = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "custom_allow_list" {
  for_each = { for n in var.ec2_network_allow_list : "${n.port}:${n.cidr}" => n }

  security_group_id = aws_security_group.this.id

  type        = "ingress"
  from_port   = each.value.port
  to_port     = each.value.port
  protocol    = each.value.protocol
  description = each.value.description

  # Access from the VPC is always allowed
  cidr_blocks = [each.value.cidr]
}

resource "aws_security_group_rule" "allow_ssh_from_vpc" {
  security_group_id = aws_security_group.this.id

  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  description = "Allow SSH from VPC"

  # Access from the VPC is always allowed
  cidr_blocks = [data.aws_vpc.vpc_data.cidr_block]
}

resource "aws_security_group_rule" "worker_egress" {
  security_group_id = aws_security_group.this.id

  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  description = "Allow all egress"
  cidr_blocks = ["0.0.0.0/0"]
}

#########
# Redis
#########

resource "aws_elasticache_replication_group" "redis_cluster" {
  replication_group_id = substr("${local.final_name}-redis-db-cluster", 0, 40)
  description          = "Redis cluster for the ${local.final_name} environment."

  engine         = "redis"
  engine_version = var.engine_version
  node_type      = var.elasticache_instance_type
  port           = 6379

  parameter_group_name = aws_elasticache_parameter_group.param_group.name
  security_group_ids   = [aws_security_group.redis_sg.id]
  subnet_group_name    = aws_elasticache_subnet_group.redis_subnet_group.name

  maintenance_window = var.maintenance_window

  at_rest_encryption_enabled = true
  transit_encryption_enabled = var.enable_transit_encryption

  multi_az_enabled           = var.enable_multi_az
  automatic_failover_enabled = var.shard_count > 1 ? true : var.enable_automatic_failover

  #Number of nodes when non-cluster mode
  num_cache_clusters = var.shard_count == 1 ? var.node_count : null

  #Nodes per shard in cluster mode
  num_node_groups         = var.shard_count > 1 ? var.shard_count : null
  replicas_per_node_group = var.shard_count > 1 ? var.node_count - 1 : null

}

resource "aws_security_group" "redis_sg" {
  name_prefix = "${var.env_name}-redis-sg"
  description = "Allow Redis traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "Redis Traffic from Trusted Networks"
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = var.internal_trusted_networks
  }

  ingress {
    description = "Redis Traffic from within VPC"
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.vpc_data.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env_name} redis sg"
  }
}

resource "aws_elasticache_parameter_group" "param_group" {
  family = var.elasticache_db_parameter_group_family
  name   = "${local.final_name}-redis-param-group"

  dynamic "parameter" {
    for_each = var.elasticache_db_parameter_group_parameters
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }
}

resource "aws_elasticache_subnet_group" "redis_subnet_group" {
  name = "${local.final_name}-redis-subnet-group"

  //use as many subnets as nodes wanted, up to the total number of subnets
  subnet_ids = var.node_count > 1 ? slice(var.subnets, 0, min(var.node_count, length(var.subnets))) : [var.subnets[0]]
}


#################
# DNS (Optional)
#################

data "aws_route53_zone" "domain" {
  count = var.lb_dns_alias == null ? 0 : 1

  zone_id = var.domain_zone_id
}

resource "aws_route53_record" "record" {
  count = var.lb_dns_alias == null ? 0 : 1

  zone_id = data.aws_route53_zone.domain[0].id
  name    = var.lb_dns_alias
  type    = var.dns_record_type
  ttl     = var.dns_ttl
  records = [aws_lb.this.dns_name]
}

# S3 Bucket

resource "aws_s3_bucket" "example" {
  bucket = var.bucket_name

  tags = {
    Name        = var.bucket_name
    Environment = var.env_name
    Stack       = var.stack_name
  }
}