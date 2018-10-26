provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "daas360cloud-remote-state-dev"
    key    = "global/vpc/vpc.tfstate"
    region = "us-east-1"
  }
}

module "vpc" {
  source = "../modules/terraform-aws-vpc"

  name             = "training-vpc"
  cidr             = "${var.cidr}"
  azs              = "${var.azs}"
  private_subnets  = "${var.private_subnets}"
  public_subnets   = "${var.public_subnets}"
  database_subnets = "${var.database_subnets}"

  create_database_subnet_group = false
  enable_nat_gateway           = true
  enable_vpn_gateway           = true

  enable_s3_endpoint       = true
  enable_dynamodb_endpoint = false
  enable_dns_hostnames     = true
  enable_dns_support       = true

  enable_dhcp_options              = true
  dhcp_options_domain_name         = "ec2.internal"
  dhcp_options_domain_name_servers = "${var.dhcp_options_domain_name_servers}"

  tags = {
    Owner       = "ECS-DEVTEAM"
    Environment = "${var.env}"
  }
}
