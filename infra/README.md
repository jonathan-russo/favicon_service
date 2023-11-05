# Favicon Terraform Module

We can autogenerate a readme with the [terraform-docs](https://terraform-docs.io/) tool.  Use this command to generate:

```bash
terraform-docs markdown table --anchor=false . > README.md
```

Edit the header comment in `main.tf` for any changes.

## Summary

This module will provision all the infrastructure necessary to run the favicon service.   This is comprised of the following:
- ALB Load Balancer
- Target group.
- AutoScaling Group
- S3 Bucket to hold deployment object

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| aws | 5.24.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_autoscaling_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_iam_instance_profile.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_launch_template.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_lb.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener.https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_target_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_route53_record.record](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_s3_bucket.example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_security_group.internal_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.allow_ssh_from_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.custom_allow_list](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.lb_allow_all_egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.lb_allow_http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.lb_allow_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.worker_egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_ami.ubuntu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_route53_zone.domain](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |
| [aws_vpc.vpc_data](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| ami\_id | AMI to specify in the Launch Template.  Takes precedence over ami\_search\_tags.  Optional | `string` | `null` | no |
| ami\_search\_tags | A map containing tags to use in a search for an AMI.  Optional. | `map(any)` | `{}` | no |
| asg\_desired | Desired number of instances to run in the ASG.  Terraform is set to ignore changes for this value so it likely will be changed by outside processes. | `number` | `1` | no |
| asg\_max | Maximum number of instances to run in the ASG.  Terraform is set to ignore changes for this value so it likely will be changed by outside processes. | `number` | `2` | no |
| asg\_min | Minimum number of instances to run in the ASG.  Terraform is set to ignore changes for this value so it likely will be changed by outside processes. | `number` | `1` | no |
| asg\_tags | Tags to add to the Auto Scaling Group and associated EC2 Instances.  Optional | `map(any)` | `null` | no |
| aws\_account\_id | AWS account to provision resources. | `string` | n/a | yes |
| aws\_region | The AWS Region to provision resources. | `string` | n/a | yes |
| bucket\_name | Name of the S3 bucket to store deployment object. | `string` | n/a | yes |
| custom\_lt\_tags | Tags to add to the Launch Template.  Additive to the default tags.  Optional | `map(any)` | `null` | no |
| dns\_record\_type | n/a | `string` | `"CNAME"` | no |
| dns\_ttl | n/a | `string` | `"300"` | no |
| domain\_zone\_id | n/a | `string` | `null` | no |
| ec2\_key\_pair | EC2 Key Pair to attach to the worker EC2 Instances. | `string` | n/a | yes |
| ec2\_network\_allow\_list | List of maps containing port, cidr, protocol, and description to add to the EC2 Security Group.  SSH access from VPC enabled by default. | <pre>set(object({<br>    port        = number<br>    cidr        = string<br>    protocol    = string<br>    description = string<br>  }))</pre> | `[]` | no |
| enable\_tg\_stickiness | Whether or not to enable Sticky Sessions on the Load Balancer. | `bool` | `false` | no |
| env\_name | Name of the environment this LB is serving.  Will be used in default name. | `string` | n/a | yes |
| health\_check\_grace\_period | Health Check Grace Period for the ASG | `number` | `300` | no |
| health\_check\_type | Health Check Type for the ASG | `string` | `"ELB"` | no |
| instance\_type | Instance type to use when running EC2 instances | `string` | n/a | yes |
| internal\_load\_balancer | Whether to make the load balancer internal only or not. | `bool` | `true` | no |
| internal\_trusted\_networks | List of networks to allow access to the LB when internal.  Ignored if lb\_security\_group\_list is specified | `list(string)` | `[]` | no |
| lb\_dns\_alias | n/a | `string` | `null` | no |
| lb\_idle\_timeout | The time in seconds that the connectio is allowed to be idle. | `number` | `60` | no |
| lb\_name\_override | Override the default name of the load balancer with this variable. | `string` | `null` | no |
| lb\_security\_group\_list | List of Security Groups to attach to the LB.  Required if LB is public, otherwise optional. | `list(string)` | `[]` | no |
| managed\_policy\_arns | List of managed policy ARNs to attach to the IAM Role that is attached to the ASG EC2. | `set(string)` | `[]` | no |
| redirect\_http | Set to true to redirect http traffic to https.  Set to false to forward http traffic to the TG | `bool` | `true` | no |
| ssl\_certificate\_arn | SSL Certificate ARN of the domain we want to use for SSL Offloading. | `string` | n/a | yes |
| ssl\_security\_policy | SSL Security Policy for our Load Balancer. | `string` | n/a | yes |
| stack\_name | Name of the stack this LB is serving. Will be used in default name. | `string` | n/a | yes |
| subnets | List of subnets to deploy the EC2 Instances in. | `list(string)` | n/a | yes |
| target\_group\_arn\_list | List of Target Group ARNs to add ASG instances to.  Optional | `list(string)` | `[]` | no |
| target\_group\_health\_check\_interval | The interval for how often the TG should send a health check. | `number` | `30` | no |
| target\_group\_health\_check\_path | The health check the target group can use to verify the health of the service | `string` | n/a | yes |
| target\_group\_healthy\_threshold | The number of consecutive health checks needed to ensure a host is healthy | `number` | `3` | no |
| target\_group\_port | The port the target group will use. | `number` | `443` | no |
| target\_group\_protocol | The protocol the target group will use. | `string` | `"HTTPS"` | no |
| target\_group\_unhealthy\_threshold | The number of consecutive health checks that need to fail to declare a host unhealthy | `number` | `3` | no |
| tg\_name\_override | Override the default name of the target group with this variable. | `string` | `null` | no |
| tg\_sticky\_duration | The time period, in seconds, during which requests from a client should be routed to the same target. | `number` | `86400` | no |
| vpc\_id | The VPC ID to install this in. | `string` | n/a | yes |

## Outputs

No outputs.
