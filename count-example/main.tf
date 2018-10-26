# Create key using awscli 
# aws ec2 create-key-pair --key-name nginx --query 'KeyMaterial' --output text >nginx.pem
# 

provider "aws" {
  region = "${var.region}"
}

# EC2 resource

resource "aws_instance" "web-nginx" {
  ami                    = "${var.ami_id}"
  instance_type          = "${var.instancetype}"
  count                  = 3
  key_name               = "nginx"
  subnet_id              = "${var.subnetid}"
  vpc_security_group_ids = ["${aws_security_group.webnginx.id}"]

  user_data = "${file("user-data.sh")}"
  tags {
    Name = "${var.AppName}-${count.index}"
    Env  = "${var.Env}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Adding Security Group for our Instance :
resource "aws_security_group" "webnginx" {
  name        = "web-nginx"
  description = "Nginx Web Server Security Group"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.HostIp}"]
  }
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.PvtIp}"]
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

resource "aws_elb" "web" {
  name = "nginx-elb"

  # The same availability zone as our instances
  availability_zones = ["${aws_instance.web-nginx.*.availability_zone}"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  # The instances are registered automatically
  instances = ["${aws_instance.web-nginx.*.id}"]
}

