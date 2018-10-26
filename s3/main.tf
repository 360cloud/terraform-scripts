provider "aws" {
  region = "us-east-1"
}

# AWS S3 Resource Bucket To be used for Remote State
resource "aws_s3_bucket" "remote_state_bucket" {
  bucket        = "daas360cloud-remote-state-dev"
  acl           = "private"
  force_destroy = "true"
  versioning {
    enabled = true
  }
}

