locals {
  timestamp = "${formatdate("YYYY-MM-DD-hhmmss", timestamp())}"
}

packer {
  required_plugins {
    amazon = {
      # https://github.com/hashicorp/packer-plugin-amazon/releases
      version = ">= 1.0.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "amazon-linux" {
  ami_name      = "favicon-${local.timestamp}"
  instance_type = "t3.micro"
  region        = "us-east-1"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-focal-20.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ec2-user"

  encrypt_boot = true

  launch_block_device_mappings {
    device_name           = "/dev/xvda"
    encrypted             = true
    volume_size           = 40
    delete_on_termination = true
  }

  tags = {
    Name = "favicon-${local.timestamp}"
  }
}

build {
  name = "favicon"
  sources = [
    "source.amazon-ebs.amazon-linux"
  ]

  provisioner "shell" {
    script = "packer-bake.sh"
    execute_command = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
  }
}
