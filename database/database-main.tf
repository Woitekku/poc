### database/main.tf

# Random DB password
resource "random_string" "database-password" {
  length = 16
  special = false
}

# Relational Database Service subnet group
resource "aws_db_subnet_group" "poc-rds-sng" {
  name = "poc-rds-sng"
  subnet_ids = "${var.poc_prv_sn.*.id}"
  
  tags = {
    Name = "poc-rds-sng"
  }
}

# Relational Database Service instance
resource "aws_db_instance" "poc-rds" {
  identifier = "poc-rds"
  allocated_storage = 5
  engine = "mysql"
  engine_version = "5.6.35"
  instance_class = "db.t2.micro"
  name = "${var.database_name}"
  username = "${var.database_username}"
  password = "${random_string.database-password.result}"
  db_subnet_group_name = "${aws_db_subnet_group.poc-rds-sng.id}"
  vpc_security_group_ids = ["${var.poc_rds_sg.id}"]
  skip_final_snapshot = true
  final_snapshot_identifier = "Ignore"
}

# Relational Database Service parameters group
resource "aws_db_parameter_group" "poc-rds-pg" {
  name = "poc-rds-pg"
  family = "mysql5.6"
  
  parameter {
    name  = "character_set_server"
    value = "utf8"
  }
  
  parameter {
    name  = "character_set_client"
    value = "utf8"
  }
}