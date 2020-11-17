# ---------------------------------------------------------------------------------------------------------------------
# VERSIONING
# This project was written for Terraform 0.13.x
# See 'Upgrading to Terraform v0.13' https://www.terraform.io/upgrade-guides/0-13.html
# ---------------------------------------------------------------------------------------------------------------------

terraform {
  required_version = ">= 0.13"
}

# ---------------------------------------------------------------------------------------------------------------------
# CONFIGURE INSTANCE CONFIGURATION TEMPLATE THAT AN AUTO SCALING GROUP USES TO LAUNCH EC2 INSTANCES
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_launch_configuration" "example" {
  image_id        = var.ami
  instance_type   = var.instance_type
  security_groups = [aws_security_group.instance.id]
  user_data       = var.user_data

  # Required when using a launch configuration with an auto scaling group.
  # https://www.terraform.io/docs/providers/aws/r/launch_configuration.html
  lifecycle {
    create_before_destroy = true
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE AN AUTO SCALING GROUP
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_autoscaling_group" "example" {
  # Explicitly depend on the launch configuration's name so each time 
  # it's replaced, this ASG is also replaced
  name = "${var.name}-${var.environment}-${aws_launch_configuration.example.name}"

  launch_configuration = aws_launch_configuration.example.name

  vpc_zone_identifier = var.subnet_ids

  # Configure integrations with a load balancer
  load_balancers    = var.load_balancers
  health_check_type = var.health_check_type

  min_size = var.min_size
  max_size = var.max_size

  # Wait for at least this many instances to pass health checks before
  # considering the ASG deployment complete
  min_elb_capacity = var.min_size

  # When replacing this ASG, create the replacement first, and only delete the
  # original after
  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = var.name
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = {
      for key, value in var.custom_tags :
      key => upper(value)
      if key != "Name"
    }

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE A SECURITY GROUP THAT CONTROLS WHAT TRAFFIC CAN GO IN AND OUT OF THE EC2 INSTANCES
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "instance" {
  name = "${var.name}-instance"
}
