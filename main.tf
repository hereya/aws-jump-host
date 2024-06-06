terraform {
  required_version = ">=1.2.0, <2.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~>4.0"
    }
  }
}

provider "aws" {}

provider "tls" {}


data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
  filter {
    name   = "default-for-az"
    values = [true]
  }
}

resource "random_id" "suffix" {
  byte_length = 8
}

resource "aws_instance" "my_instance" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  subnet_id              = data.aws_subnets.public.ids[0]
  vpc_security_group_ids = [
    aws_security_group.my_instance.id
  ]
  key_name = aws_key_pair.web.key_name
  tags     = {
    Name = local.name_prefix
  }
}

resource "aws_security_group" "my_instance" {
  name = "${local.name_prefix}-${lower(random_id.suffix.hex)}"
}


resource "aws_security_group_rule" "allow_ssh" {
  security_group_id = aws_security_group.my_instance.id
  type              = "ingress"
  from_port         = local.ssh_port
  to_port           = local.ssh_port
  protocol          = local.tcp_protocol
  cidr_blocks       = local.any_ip
}

resource "aws_security_group_rule" "allow_icmp" {
  security_group_id = aws_security_group.my_instance.id
  type              = "ingress"
  from_port         = -1
  to_port           = -1
  protocol          = "icmp"
  cidr_blocks       = local.any_ip
}


resource "aws_security_group_rule" "allow_all_outbound" {
  security_group_id = aws_security_group.my_instance.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = local.any_protocol
  cidr_blocks       = local.any_ip
}

resource "tls_private_key" "ssh_rsa_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "web" {
  key_name   = "jump-host-key-${random_id.suffix.hex}"
  public_key = tls_private_key.ssh_rsa_key.public_key_openssh
}

resource "aws_ssm_parameter" "ssh_private_key" {
  name = "/hereya/jump-host/${aws_instance.my_instance.id}"
  type = "SecureString"
  value = tls_private_key.ssh_rsa_key.private_key_pem
}


locals {
  ssh_port     = 22
  tcp_protocol = "tcp"
  any_ip       = ["0.0.0.0/0"]
  any_protocol = "-1"
  name_prefix  = "my-instance"
}
