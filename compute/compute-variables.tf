### compute/variables.tf

variable "public_key_path" {}
variable "poc_rds_endpoint" {}
variable "region" {}
variable "poc_database_name" {}
variable "poc_database_username" {}
variable "poc_database_password" {}
variable "poc_bucket" {}
variable "ami" {}
variable "instance_type" {}
variable "poc_pub_sn" {}
variable "poc_prv_sn" {}
variable "poc_bastion_sg" {}
variable "poc_ec2_sg" {}
variable "poc_s3_access_profile" {}
variable "asg_ec2_min_size" {}
variable "asg_ec2_max_size" {}
variable "poc_alb_tg" {}
variable "bastion_hostname" {}
variable "health_check_path" {}
variable "poc_route53_zone" {}