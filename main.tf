# root/main.tf
provider "aws" {
    profile = "${var.aws_profile}"
    region = "${var.aws_region}"
    access_key = "${var.aws_access_key_id}"
    secret_key = "${var.aws_secret_access_key}"
}

module "iam" {
    source = "./iam"
    region = "${var.aws_region}"
    poc_vpc = "${module.networking.poc_vpc}"
    poc_prv_rt = "${module.networking.poc_prv_rt}"
    poc_bucket = "${module.storage.poc_bucket}"
}
module "networking" {
    source = "./networking"
    hosted_zone_name = "${var.hosted_zone_name}"
    delegation_set = "${var.delegation_set}"
    vpc_cidr = "${var.vpc_cidr}"
    accessip = "${var.accessip}"
}

module "storage" {
    source = "./storage"
}

module "database" {
    source = "./database"
    poc_prv_sn = "${module.networking.poc_prv_sn}"
    database_name = "${var.database_name}"
    database_username = "${var.database_username}"
    poc_rds_sg = "${module.networking.poc_rds_sg}"
}

module "compute" {
    source = "./compute"
    public_key_path = "${var.public_key_path}"
    poc_rds_endpoint = "${module.database.poc_rds_endpoint}"
    region = "${var.aws_region}"
    poc_database_name = "${module.database.poc_database_name}"
    poc_database_username = "${module.database.poc_database_username}"
    poc_database_password = "${module.database.poc_database_password}"
    poc_bucket = "${module.storage.poc_bucket}"
    ami = "${var.ami}"
    instance_type = "${var.instance_type}"
    poc_pub_sn = "${module.networking.poc_pub_sn}"
    poc_prv_sn = "${module.networking.poc_prv_sn}"
    poc_bastion_sg = "${module.networking.poc_bastion_sg}"
    poc_ec2_sg = "${module.networking.poc_ec2_sg}"
    poc_s3_access_profile = "${module.iam.poc_s3_access_profile}"
    poc_alb_tg = "${module.networking.poc_alb_tg}"
    asg_ec2_min_size = "${var.asg_ec2_min_size}"
    asg_ec2_max_size = "${var.asg_ec2_max_size}"
}