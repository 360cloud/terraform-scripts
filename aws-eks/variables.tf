variable "region" {
  default = "us-east-1"
}
variable "cluster-name" {
  default = "aws-eks"
  type    = "string"
}

variable "key_name" {
  default = "blockgraph-kubernetes"
  type    = "string"
}

