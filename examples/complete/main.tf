# ---------------------------------------------------------------------------------------------------------------------
# VERSIONING
# This project was written for Terraform 0.13.x
# See 'Upgrading to Terraform v0.13' https://www.terraform.io/upgrade-guides/0-13.html
# ---------------------------------------------------------------------------------------------------------------------

terraform {
  required_version = ">= 0.13"
}

provider "aws" {
  region = "us-east-1"

  # Allow any 2.x version of the AWS provider
  version = "~> 2.0"
}


# ---------------------------------------------------------------------------------------------------------------------
# CREATE AN AUTO SCALING GROUP
# ---------------------------------------------------------------------------------------------------------------------

module "asg" {
  source = "../../"

  name        = var.name
  environment = var.environment

  ami           = "ami-02354e95b39ca8dec" # Amazon Linux
  instance_type = "t2.micro"

  min_size           = 2
  max_size           = 2

  subnet_ids        = data.aws_subnet_ids.default.ids
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE SECURITY RULE THAT ALLOWS ALL TRAFFIC IN ON THE SERVER PORT FROM ANYWHERE (TCP ONLY)
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group_rule" "allow_server_http_inbound" {
  type              = "ingress"
  security_group_id = module.asg.instance_security_group_id

  from_port   = var.server_port
  to_port     = var.server_port
  protocol    = local.tcp_protocol
  cidr_blocks = local.all_ips
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE SECURITY RULE THAT ALLOW ALL TRAFFIC OUT OF THE SERVER TO ANYWHERE
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group_rule" "allow_server_all_outbound" {
  type		     = "egress"
  security_group_id  = module.asg.instance_security_group_id

  from_port	     = local.any_port
  to_port	     = local.any_port
  protocol	     = local.any_protocol
  cidr_blocks	     = local.all_ips
}

locals {
  any_port      =  0
  any_protocol  = "-1" 
  tcp_protocol  = "tcp"
  all_ips       = ["0.0.0.0/0"]
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}

