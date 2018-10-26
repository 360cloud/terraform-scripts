# Variables TF File
variable "region" {
  description = "AWS Region "
  default  = "us-east-1"
}

variable "ami_id" {
  description = "AMI ID to be used for Instance "
  default  = "ami-0ff8a91507f77f867"
}

variable "instancetype" {
  description = "Instance Typebe used for Instance "
  default  = "t2.micro"
}

variable "subnetid" {
  description = "Subnet ID to be used for Instance "
  default  = "subnet-41d6541d"
}

variable "AppName" {
  description = "Application Name"
  default  = "Webserver-Host"
}

variable "Env" {
  description = "Application Name"
  default  = "Dev"
}

variable "HostIp" {
  description = " Host IP to be allowed SSH for"
  default  = "136.36.334.17/32"
}

variable "PvtIp" {
  description = " Host IP to be allowed SSH for"
  default  = "10.12.0.0/16"
}

variable "PvtIP" {
  description = " Host IP to be allowed SSH for"
  default  = "10.16.0.0/16"
}
