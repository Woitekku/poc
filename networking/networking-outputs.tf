### networking/outputs.tf

output "poc_vpc" {
    value = "${aws_vpc.poc-vpc}"
}

output "poc_prv_rt" {
    value = "${aws_vpc.poc-vpc.default_route_table_id}"
}

output "poc_bastion_sg" {
    value = "${aws_security_group.poc-bastion-sg}"
}

output "poc_ec2_sg" {
    value = "${aws_security_group.poc-ec2-sg}"
}

output "poc_pub_sn" {
    value = "${aws_subnet.poc-pub-sn.*}"
}

output "poc_prv_sn" {
    value = "${aws_subnet.poc-prv-sn.*}"
}

output "poc_rds_sg" {
    value = "${aws_security_group.poc-rds-sg}"
}

output "poc_alb_tg" {
    value = "${aws_alb_target_group.poc-alb-tg}"
}