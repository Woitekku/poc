### root/variables.tf

variable "aws_profile" {}
variable "aws_region" {}
variable "aws_access_key_id" {}
variable "aws_secret_access_key" {}
variable "aws_terraform_state_bucket" {}
variable "hosted_zone_name" {}
variable "delegation_set" {}
variable "vpc_cidr" {}
variable "accessip" {}
variable "database_name" {}
variable "database_username" {}
variable "public_key_path" {}
variable "ami" {}
variable "instance_type" {}
variable "asg_ec2_min_size" {}
variable "asg_ec2_max_size" {}
variable "certificate_arn" {}
variable "health_check_path" {}
variable "bastion_hostname" {}