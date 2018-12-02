terraform {
 # required_version = "= 0.11.8"

#backend "s3" {
#    bucket = "bg-remote-state-1111"
#    key    = "service/bg-eks/state.tf"
#    region = "us-east-1"
#  }
}

provider "aws" {
  version = ">= 1.24.0"
  region  = "${var.region}"
}

provider "random" {
  version = "= 1.3.1"
}

# data "terraform_remote_state" "vpc"


# data "aws_availability_zones" "available" {}

locals {
  cluster_name = "aws-eks-${random_string.suffix.result}"

  worker_groups = "${list(
                  map("asg_desired_capacity", "5",
                      "asg_max_size", "10",
                      "asg_min_size", "5",
                      "instance_type","t2.large", 
                      "key_name", "${var.key_name}",
                      "additional_userdata","echo DEV K8s cluster"
                      ),
  )}"
  tags = "${map("Environment", "aws-eks",
                "Env-Name", "DEV",
  )}"
}

resource "random_string" "suffix" {
  length  = 6
  special = false
}

module "eks" {
  source        = "../modules/aws-eks"
  cluster_name  = "${local.cluster_name}"
#  subnets       = ["${data.terraform_remote_state.vpc.public_subnets[0]}", "${data.terraform_remote_state.vpc.public_subnets[1]}"]
  subnets       = ["subnet-14cc403a", "subnet-15c5bd1a"]
  tags          = "${local.tags}"
#  vpc_id        = "${data.terraform_remote_state.vpc.vpc_id}"
  vpc_id        = "vpc-9a5280e0"
  worker_groups = "${local.worker_groups}"
}
