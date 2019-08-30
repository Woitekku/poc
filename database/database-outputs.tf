### database/outputs.tf

output "poc_rds_endpoint" {
    value = "${aws_db_instance.poc-rds.endpoint}"
}

output "poc_database_name" {
    value = "${var.database_name}"
}

output "poc_database_username" {
    value = "${var.database_username}"
}

output "poc_database_password" {
    value = "${random_string.database-password.result}"
}