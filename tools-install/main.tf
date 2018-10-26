provider "aws" {
  region = "${var.region}"
}

# EC2 resource

resource "aws_instance" "web-nginx"
{
  ami                       = "${var.ami_id}"
  instance_type             = "${var.instancetype}"
  key_name                  = "nginx-key"
  subnet_id                 = "${var.subnetid}"
  vpc_security_group_ids    = ["${aws_security_group.webnginx.id}"]
  tags {
  Name          = "${var.AppName}"
  Env           =  "${var.Env}"
}
 lifecycle {
    create_before_destroy  = true
  }

}

# Adding Security Group for our Instance :
resource "aws_security_group" "webnginx" {
        name = "web-nginx"
        description = "Nginx Web Server Security Group"
        ingress {
                from_port = 22
                to_port = 22
                protocol = "tcp"
                cidr_blocks = ["${var.HostIp}"]
              }

        ingress {
                        from_port = 80
                        to_port = 80
                        protocol = "tcp"
                        cidr_blocks = ["${var.HostIp}"]
                }
        
        ingress {
                from_port = 22
                to_port = 22
                protocol = "tcp"
                cidr_blocks = ["${var.PvtIp}"]
        }

        egress   {
                          from_port = 0
                          to_port = 0
                          protocol = "-1"
                          cidr_blocks = ["0.0.0.0/0"]
            }
  lifecycle {
    create_before_destroy  = true
  }
          }
