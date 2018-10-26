provider "aws" {
  region     = "us-east-1"
  access_key = "ACCESS_KEY"
  secret_key = "SECRET_KEY"
}


# AWS EC2 resource

resource "aws_instance" "demo" 
{
  ami           = "${var.ami_id}"
  instance_type = "${var.type}"

  tags {
    Name = "Training-1"
  }
}

# AWS S3 Resource
resource "aws_s3_bucket" "remote_state_bucket"
 {
  bucket = "daas360cloud-remote-state-dev"
  acl    = "private"
}
