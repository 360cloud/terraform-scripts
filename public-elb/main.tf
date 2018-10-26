provider "aws" {
          region = "${var.region}"
       }

terraform {
  backend "s3" {
          bucket = "daas360cloud-remote-state-dev"
          key    = "service/webservices/nginx.tfstate"
          region = "us-east-1"
  }
}

data "terraform_remote_state" "vpc"
{
    backend  = "s3"
    config {
      bucket = "daas360cloud-remote-state-dev"
      key    = "global/vpc/vpc.tfstate"
      region = "us-east-1"
    }
}

# Get Data from AWS VPC for available availability_zones

data "aws_availability_zones" "available" {}

resource "aws_launch_configuration" "training-launch-config" {
  image_id                  = "${var.ami}"
  instance_type             = "${var.instance_type}"
  key_name                  = "${var.key_name}"
  user_data                 = "${file("user-data.sh")}"
  security_groups           = ["${aws_security_group.nginx.id}"]
  associate_public_ip_address = "true"
  lifecycle {
    create_before_destroy  = true
  }
}

# AWS autoscaling_group configuration

resource "aws_autoscaling_group" "training-asg" {
  launch_configuration    = "${aws_launch_configuration.training-launch-config.id}"
  min_size                = "2"
  max_size                = "4"
  availability_zones      = ["${data.aws_availability_zones.available.names[0]}", "${data.aws_availability_zones.available.names[1]}"]
  load_balancers          = ["${aws_elb.sig-svc.id}"]
  health_check_type       = "ELB"
  vpc_zone_identifier     = ["${data.terraform_remote_state.vpc.public_subnets}"]
  tags {
    key                   = "Name"
    value                 = "${var.cluster_name}-ASG"
    propagate_at_launch   = "true"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_policy" "cpu-usage" {
  name                    = "${var.cluster_name}-asg-cpu-policy"
  autoscaling_group_name  = "${aws_autoscaling_group.training-asg.name}"
  policy_type             = "TargetTrackingScaling"
  target_tracking_configuration {
  predefined_metric_specification {
  predefined_metric_type  = "ASGAverageCPUUtilization"
    }
    target_value          = 70.0
  }
}

resource "aws_elb" "sig-svc" {
  name = "${var.cluster_name}"
  subnets                     = ["${data.terraform_remote_state.vpc.public_subnets}"]
  security_groups             = ["${aws_security_group.training-sg1.id}"]
  internal                    = false
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  listener {
    instance_port             = "80"
    instance_protocol         = "HTTP"
    lb_port                   = "80"
    lb_protocol               = "HTTP"
  }

  health_check {
    target                    = "TCP:80"
    interval                  = 30
    healthy_threshold         = 2
    unhealthy_threshold       = 2
    timeout                   = 10
  }

  tags {
   ServerName = "Webserver Nginx"
  }
}
# ELB Security Group
resource "aws_security_group" "training-sg1" {
  name                       = "${var.cluster_name}-ELB-SG"
  description                = "Allow all - ${data.terraform_remote_state.vpc.vpc_id}"
  vpc_id                     = "${data.terraform_remote_state.vpc.vpc_id}"
  ingress {
    from_port                = 80
    to_port                  = 80
    protocol                 = "tcp"
    cidr_blocks              = ["0.0.0.0/0"]
  }
  egress {
    from_port                = 0
    to_port                  = 0
    protocol                 = "-1"
    cidr_blocks              = ["0.0.0.0/0"]
  }
  lifecycle {

    create_before_destroy = true
  }
}

# Nginx Instance Security Group
resource "aws_security_group" "nginx" {
        name        = "Nginx SG"
        description = "Nginx Security Group"
        vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
        ingress {
                from_port   = 22
                to_port     = 22
                protocol    = "tcp"
                cidr_blocks = ["${data.terraform_remote_state.vpc.cidr}"]
        }
        ingress {
                from_port   = 80
                to_port     = 80
                protocol    = "tcp"
                cidr_blocks = ["${data.terraform_remote_state.vpc.cidr}"]
        }

        ingress {
                from_port   = 80
                to_port     = 80
                protocol    = "tcp"
                cidr_blocks = ["${var.HostIp}"]
        }
        ingress {
                from_port       = 80
                to_port         = 80
                protocol        = "tcp"
                security_groups = ["${aws_security_group.training-sg1.id}"]
        }
        egress {
                from_port   = 0
                to_port     = 0
                protocol    = "-1"
                cidr_blocks = ["0.0.0.0/0"]
        }
  lifecycle {
    create_before_destroy = true
  }
}
