# AWS variables
variable "aws_region" {
  type        = string
  description = "The AWS Region to provision resources."
}

variable "aws_account_id" {
  type        = string
  description = "AWS account to provision resources."
}

# General Variables

variable "env_name" {
  type        = string
  description = "Name of the environment this LB is serving.  Will be used in default name."
}

variable "stack_name" {
  type        = string
  description = "Name of the stack this LB is serving. Will be used in default name."
}

variable "asg_tags" {
  type        = map(any)
  description = "Tags to add to the Auto Scaling Group and associated EC2 Instances.  Optional"
  default     = null
}

variable "custom_lt_tags" {
  type        = map(any)
  description = "Tags to add to the Launch Template.  Additive to the default tags.  Optional"
  default     = null
}

# ASG Variables

variable "instance_type" {
  type        = string
  description = "Instance type to use when running EC2 instances"
}

variable "ami_id" {
  type        = string
  description = "AMI to specify in the Launch Template.  Takes precedence over ami_search_tags.  Optional"
  default     = null
}

variable "ami_search_tags" {
  type        = map(any)
  description = "A map containing tags to use in a search for an AMI.  Optional."
  default     = {}
}

variable "asg_desired" {
  type        = number
  description = "Desired number of instances to run in the ASG.  Terraform is set to ignore changes for this value so it likely will be changed by outside processes."
  default     = 1
}

variable "asg_min" {
  type        = number
  description = "Minimum number of instances to run in the ASG.  Terraform is set to ignore changes for this value so it likely will be changed by outside processes."
  default     = 1
}

variable "asg_max" {
  type        = number
  description = "Maximum number of instances to run in the ASG.  Terraform is set to ignore changes for this value so it likely will be changed by outside processes."
  default     = 2
}

variable "managed_policy_arns" {
  type        = set(string)
  description = "List of managed policy ARNs to attach to the IAM Role that is attached to the ASG EC2."
  default     = []
}

variable "ec2_key_pair" {
  type        = string
  description = "EC2 Key Pair to attach to the worker EC2 Instances."
}

# Network Variables

variable "target_group_arn_list" {
  type        = list(string)
  description = "List of Target Group ARNs to add ASG instances to.  Optional"
  default     = []
}

variable "ec2_network_allow_list" {
  type = set(object({
    port        = number
    cidr        = string
    protocol    = string
    description = string
  }))
  description = "List of maps containing port, cidr, protocol, and description to add to the EC2 Security Group.  SSH access from VPC enabled by default."
  default     = []
}

variable "subnets" {
  type        = list(string)
  description = "List of subnets to deploy the EC2 Instances in."
}

variable "vpc_id" {
  type        = string
  description = "The VPC ID to install this in."
}

variable "health_check_type" {
  type        = string
  description = "Health Check Type for the ASG"
  default     = "ELB"
}

variable "health_check_grace_period" {
  type        = number
  description = "Health Check Grace Period for the ASG"
  default     = 300
}

variable "lb_name_override" {
  type        = string
  description = "Override the default name of the load balancer with this variable."
  default     = null
}

variable "tg_name_override" {
  type        = string
  description = "Override the default name of the target group with this variable."
  default     = null
}

variable "redirect_http" {
  type        = bool
  description = "Set to true to redirect http traffic to https.  Set to false to forward http traffic to the TG"
  default     = true
}

variable "ssl_certificate_arn" {
  type        = string
  description = "SSL Certificate ARN of the domain we want to use for SSL Offloading."
}

variable "ssl_security_policy" {
  type        = string
  description = "SSL Security Policy for our Load Balancer."
}

variable "lb_security_group_list" {
  type        = list(string)
  description = "List of Security Groups to attach to the LB.  Required if LB is public, otherwise optional."
  default     = []
}

variable "internal_trusted_networks" {
  type        = list(string)
  default     = []
  description = "List of networks to allow access to the LB when internal.  Ignored if lb_security_group_list is specified"
}


# Load Balancer/Target Group Variables

variable "internal_load_balancer" {
  type        = bool
  description = "Whether to make the load balancer internal only or not."
  default     = true
}

variable "target_group_port" {
  type        = number
  description = "The port the target group will use."
  default     = 443
}

variable "target_group_protocol" {
  type        = string
  description = "The protocol the target group will use."
  default     = "HTTPS"
}

variable "target_group_health_check_path" {
  type        = string
  description = "The health check the target group can use to verify the health of the service"
}

variable "target_group_healthy_threshold" {
  type        = number
  description = "The number of consecutive health checks needed to ensure a host is healthy"
  default     = 3
}

variable "target_group_unhealthy_threshold" {
  type        = number
  description = "The number of consecutive health checks that need to fail to declare a host unhealthy"
  default     = 3
}

variable "target_group_health_check_interval" {
  type        = number
  description = "The interval for how often the TG should send a health check."
  default     = 30
}

variable "enable_tg_stickiness" {
  type        = bool
  description = "Whether or not to enable Sticky Sessions on the Load Balancer."
  default     = false
}

variable "tg_sticky_duration" {
  type        = number
  description = "The time period, in seconds, during which requests from a client should be routed to the same target."
  default     = 86400 # 1 day
}

variable "lb_idle_timeout" {
  type        = number
  description = "The time in seconds that the connectio is allowed to be idle."
  default     = 60
}

#DNS variables

variable "lb_dns_alias" {
  type    = string
  default = null
}

variable "domain_zone_id" {
  type    = string
  default = null
}

variable "dns_record_type" {
  type    = string
  default = "CNAME"
}

variable "dns_ttl" {
  type    = string
  default = "300"
}

# S3 Vars

variable "bucket_name" {
  type        = string
  description = "Name of the S3 bucket to store deployment object."
}

# Redis Vars

variable "shard_count" {
  description = "Setting this higher than 1(default) enables cluster-mode on the Elasticache Redis deployment.  Specifies the number of shards in the cluster.  Must be used with a parameter group that sets the 'cluster-enabled' parameter."
  type        = number
  default     = 1
}

variable "node_count" {
  description = "Number of nodes to use.  Total number of nodes when in non-cluster mode. Number of nodes per shard in cluster-mode.  If more than 1 are specified the other nodes will be read replicas."
  type        = number
  default     = 1
}

variable "enable_automatic_failover" {
  description = "When enabled, a read-only replica is automatically promoted to a read-write primary cluster if the existing primary cluster fails. If you specify true, you must specify a value greater than 1 for node_count.  Enabled by default when in cluster-mode"
  type        = bool
  default     = false
}

variable "enable_multi_az" {
  description = "Specifies whether to enable Multi-AZ Support for the replication group. If true, automatic_failover_enabled must also be enabled. Defaults to false."
  type        = bool
  default     = false
}

variable "elasticache_instance_type" {
  description = "The node type to use for the Cluster."
  type        = string
  default     = "cache.m4.large"
}

variable "engine_version" {
  description = "Redis Engine version to use for the Elasticache cluster. Must match the parameter group specified or auto-generated through elasticache_db_parameter_group_family"
  type        = string
  default     = "7.0"
}

variable "elasticache_db_parameter_group_family" {
  description = "Family to use for the Elasticache parameter group to create. Must match the engine version"
  type        = string
  default     = "redis7"
}

variable "elasticache_db_parameter_group_parameters" {
  description = "Map of values to set in the Elasticache parameter group. Only applies if elasticache_db_parameter_group_name not set."
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "maintenance_window" {
  description = "Time for the maintenance window.  UTC"
  type        = string
  default     = "fri:03:00-fri:04:00"
}

variable "enable_transit_encryption" {
  description = "Whether to enable encryption in transit."
  type        = bool
  default     = true
}