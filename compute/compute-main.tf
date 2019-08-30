### compute/main.tf

## SSH keys
resource "aws_key_pair" "poc-keys" {
  key_name = "poc-keys"
  public_key = "${file(var.public_key_path)}"
}

# Bastion Host Elastic IP
resource "aws_eip" "poc-eip-bastion" {
  vpc = true
  
  tags = {
    Name = "poc-eip-bastion"
  }
}

# Bastion host
resource "aws_instance" "poc-bastion" {
  ami = "${var.ami}"
  instance_type = "${var.instance_type}"
  key_name = "${aws_key_pair.poc-keys.id}"
  subnet_id = "${var.poc_pub_sn[0].id}"
  security_groups = ["${var.poc_bastion_sg.id}"]
  associate_public_ip_address = true
  
  tags = {
    Name = "poc-bastion"
  }
}

resource "aws_eip_association" "poc-eip-bastion" {
  allocation_id = "${aws_eip.poc-eip-bastion.id}"
  instance_id = "${aws_instance.poc-bastion.id}"
}

resource "aws_cloudwatch_metric_alarm" "poc-bastion-auto-recovery-alarm" {
  alarm_name          = "EC2AutoRecover-${aws_instance.poc-bastion.id}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "3"
  metric_name         = "StatusCheckFailed_System"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Minimum"

  dimensions = {
    InstanceId = "${aws_instance.poc-bastion.id}"
  }

  alarm_actions = ["arn:aws:automate:${var.region}:ec2:recover"]
  threshold         = "1"
  alarm_description = "Auto recover the EC2 instance if Status Check fails."
}

resource "aws_route53_health_check" "poc-route53-health-check" {
  ip_address        = "${aws_eip.poc-eip-bastion.public_ip}"
  port              = 80
  type              = "HTTP"
  resource_path     = "${var.health_check_path}"
  failure_threshold = "5"
  request_interval  = "10"

  tags = {
    Name = "poc-route53-health-check"
  }
}

resource "aws_route53_record" "poc-route53-record" {
  zone_id = "${var.route53_hosted_zone_id}"
  name    = "${var.hosted_zone_name}"
  type    = "A"
  ttl     = "60"

  weighted_routing_policy {
    weight = 10
  }

  set_identifier  = "${aws_instance.poc-bastion.id}"
  records         = ["${aws_eip.poc-eip-bastion.public_ip}"]
  health_check_id = "${aws_route53_health_check.poc-route53-health-check.id}"
}


























# Bastion host
resource "aws_instance" "poc-bastion" {
  ami = "${var.ami}"
  instance_type = "${var.instance_type}"
  key_name = "${aws_key_pair.poc-keys.id}"
  subnet_id = "${var.poc_pub_sn[0].id}"
  security_groups = ["${var.poc_bastion_sg.id}"]
  associate_public_ip_address = true
  
  tags = {
    Name = "poc-bastion"
  }
}

# Provisioning template
data "template_file" "provisioning" {
  template = "${file("provisioning.sh")}"

  vars = {
    region = "${var.region}"
    database_endpoint = "${var.poc_rds_endpoint}"
    database_name = "${var.poc_database_name}"
    database_username = "${var.poc_database_username}"
    database_password = "${var.poc_database_password}"
    poc_bucket = "${var.poc_bucket.id}"
  }
}

resource "aws_launch_configuration" "poc-ec2-lc" {
  name_prefix = "poc-ec2-"
  image_id = "${var.ami}"
  instance_type = "${var.instance_type}"
  key_name = "${aws_key_pair.poc-keys.id}"
  security_groups = ["${var.poc_ec2_sg.id}"]
  associate_public_ip_address = false
  iam_instance_profile = "${var.poc_s3_access_profile.id}"
  user_data = "${data.template_file.provisioning.rendered}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "poc-ec2-asg" {
  name = "poc-ec2-asg"
  launch_configuration = "${aws_launch_configuration.poc-ec2-lc.id}"
  min_size = "${var.asg_ec2_min_size}"
  max_size = "${var.asg_ec2_max_size}"
  target_group_arns = ["${var.poc_alb_tg.arn}"]
  vpc_zone_identifier = "${var.poc_prv_sn.*.id}"
  
  lifecycle {
    create_before_destroy = true
  }
  
  tag {
    key = "Name"
    value = "poc-ec2-asg"
    propagate_at_launch = true
  }
}