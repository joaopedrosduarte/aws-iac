variable "region" {
  default = "us-west-2"
}

variable "vpc_cidr" {
  default = "107.0.0.0/20"
}

variable "availability_zone1" {
  default = "us-west-2a"
}

variable "availability_zone2" {
  default = "us-west-2b"
}

variable "cidr_subnet1" {
  default = "107.0.1.0/24"
}

variable "cidr_subnet2" {
  default = "107.0.2.0/24"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "db_password" {}

# Here's the project reference https://inshiya-nalawala211.medium.com/configure-wordpress-on-aws-ec2-with-rds-mysql-using-terraform-a83eb4ec7aef
