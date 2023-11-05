# General
env_name = "production"
stack_name = "favicon"
instance_type = "c5.large"
ec2_key_pair = "my-key-pair" # Replace Me
bucket_name = "deploy-production-favicon"

asg_tags = {
  "environment" : "production",
  "stack": "favicon",
}
managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonS3FullAccess"
]


# Networking
vpc_id = "vpc-11111111" # Replace Me
subnets = [ "subnet-11111111" ] # Replace Me
target_group_port = 8000
target_group_protocol = "HTTP"
target_group_health_check_path = "/health"
ssl_certificate_arn = "arn:aws:acm:us-east-1:111111111111:certificate/11111111-1111-1111-111111111111" # Replace Me
ssl_security_policy = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
internal_trusted_networks = [ "10.0.0.0/8" ] # Replace Me

# AWS vars
aws_region = "us-east-1"
aws_account_id = "111111111111" # Replace Me
