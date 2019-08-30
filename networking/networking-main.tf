### networking/main.tf

# Read available zones
data "aws_availability_zones" "available" {}

# Route53 subdomain, using reusable delegation set
# aws route53 create-reusable-delegation-set --caller-reference "$(date)" --profile cloudificationpoc
resource "aws_route53_zone" "poc-route53-zone" {
  name = "${var.hosted_zone_name}"
  delegation_set_id = "${var.delegation_set}"
  
  tags = {
    Name = "poc-route53-zone"
  }

}

# Generate SSL certificate
#resource "aws_acm_certificate" "poc-ssl-cert" {
#  domain_name = "${var.hosted_zone_name}"
#  validation_method = "DNS"
#  
#  lifecycle {
#    create_before_destroy = true
#  }
#  
#  tags = {
#    Name = "poc-ssl-cert"
#  }
#
#}

# Add CNAME record for DNS validation 
#resource "aws_route53_record" "poc-ssl-cert" {
#  name = "${aws_acm_certificate.poc-ssl-cert.domain_validation_options.0.resource_record_name}"
#  type = "${aws_acm_certificate.poc-ssl-cert.domain_validation_options.0.resource_record_type}"
#  zone_id = "${aws_route53_zone.poc-route53-zone.id}"
#  records = ["${aws_acm_certificate.poc-ssl-cert.domain_validation_options.0.resource_record_value}"]
#  ttl = 60
#}

# Validate the certificate
#resource "aws_acm_certificate_validation" "poc-ssl-cert" {
#  certificate_arn = "${aws_acm_certificate.poc-ssl-cert.arn}"
#  validation_record_fqdns = ["${aws_route53_record.poc-ssl-cert.fqdn}"]
#}


# Virtual Private Cloud
resource "aws_vpc" "poc-vpc" {
    cidr_block = "${var.vpc_cidr}"
    
    tags = {
        Name = "poc-vpc"
    }
}

# Internet Gateway
resource "aws_internet_gateway" "poc-igw" {
  vpc_id = "${aws_vpc.poc-vpc.id}"

  tags = {
    Name = "poc-igw"
  }
}

# Public Subnets
resource "aws_subnet" "poc-pub-sn" {
  count = "${length(data.aws_availability_zones.available.names)}"
  vpc_id = "${aws_vpc.poc-vpc.id}"
  cidr_block = "10.0.${count.index}.0/25"
  map_public_ip_on_launch = true
  availability_zone = "${element(data.aws_availability_zones.available.names, count.index)}"

  tags = {
    Name = "poc-pub-sn${count.index}"
  }
}

# Private Subnets
resource "aws_subnet" "poc-prv-sn" {
  count = "${length(data.aws_availability_zones.available.names)}"
  vpc_id = "${aws_vpc.poc-vpc.id}"
  cidr_block = "10.0.${count.index}.128/25"
  map_public_ip_on_launch = false
  availability_zone = "${element(data.aws_availability_zones.available.names, count.index)}"

  tags = {
    Name = "poc-prv-sn${count.index}"
  }
}

# Elastic IP Address for NAT Gateway
resource "aws_eip" "poc-eip-ngw" {
  vpc = true
  depends_on = ["aws_internet_gateway.poc-igw"]
  
  tags = {
    Name = "poc-eip-ngw"
  }
}
  
# NAT Gateway
resource "aws_nat_gateway" "poc-ngw" {
  allocation_id = "${aws_eip.poc-eip-ngw.id}"
  subnet_id = "${aws_subnet.poc-pub-sn[0].id}"
  depends_on = ["aws_internet_gateway.poc-igw"]
  
  tags = {
    Name = "poc-ngw"
  }
}

# Public Route Table
resource "aws_route_table" "poc-pub-rt" {
  vpc_id = "${aws_vpc.poc-vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.poc-igw.id}"
  }

  tags = {
    Name = "poc-pub-rt"
  }
}

# Private Route Table
resource "aws_default_route_table" "poc-prv-rt" {
  default_route_table_id = "${aws_vpc.poc-vpc.default_route_table_id}"

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.poc-ngw.id}"
  }
  
  tags = {
    Name = "poc-prv-rt"
  }
}

# Subnets to Route Tables Association
resource "aws_route_table_association" "poc-pub-sn-rt" {
  count = "${length(aws_subnet.poc-pub-sn)}"
  subnet_id = "${element(aws_subnet.poc-pub-sn.*.id, count.index)}"
  route_table_id = "${aws_route_table.poc-pub-rt.id}"
}

resource "aws_route_table_association" "poc-prv-sn-rt" {
  count = "${length(aws_subnet.poc-prv-sn)}"
  subnet_id = "${element(aws_subnet.poc-prv-sn.*.id, count.index)}"
  route_table_id = "${aws_default_route_table.poc-prv-rt.id}"
}

# Bastion host security group, access only over SSH TCP/22
resource "aws_security_group" "poc-bastion-sg" {
  name = "poc-bastion-sg"
  vpc_id = "${aws_vpc.poc-vpc.id}"
  
  ingress { 
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${var.accessip}"]
  }
  
  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "poc-bastion-sg"
  }
}

# Application Load Balancer security group, access only over HTTP TCP/80 and HTTPS TCP/443
resource "aws_security_group" "poc-alb-sg" {
  name = "poc-alb-sg"
  vpc_id = "${aws_vpc.poc-vpc.id}"
  
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["${var.accessip}"]
  }
  
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["${var.accessip}"]
  }
  
  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  
   tags = {
    Name = "poc-alb-sg"
  }
}

# Security Groups
resource "aws_security_group" "poc-ec2-sg" {
  name = "poc-ec2-sg"
  vpc_id = "${aws_vpc.poc-vpc.id}"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    security_groups = ["${aws_security_group.poc-bastion-sg.id}"]
  } 
  
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    security_groups = ["${aws_security_group.poc-alb-sg.id}"]
  }
  
  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["${var.accessip}"]
  }
  
  tags = {
    Name = "poc-ec2-sg"
  }
}

resource "aws_security_group" "poc-rds-sg" {
  name = "poc-rds-sg"
  vpc_id = "${aws_vpc.poc-vpc.id}"
  
  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    security_groups = ["${aws_security_group.poc-ec2-sg.id}"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "poc-rds-sg"
  }
}

# Application Load Balancer
resource "aws_alb" "poc-alb" {
  name = "poc-alb"
  load_balancer_type = "application"
  internal = false
  security_groups = ["${aws_security_group.poc-alb-sg.id}"]
  subnets = "${aws_subnet.poc-pub-sn.*.id}"
  
  tags = {
    Name = "poc-alb"
  }
}

# Application Load Balancer Target Group
resource "aws_alb_target_group" "poc-alb-tg" {
  name = "poc-alb-tg"
  vpc_id = "${aws_vpc.poc-vpc.id}"
  port = 80
  protocol = "HTTP"
  
  stickiness {
    type = "lb_cookie"
  }

  health_check {
    path = "/login"
    port = 80
  }
  
  tags = {
    Name = "poc-alb-tg"
  }
}

# Application Load Balancer HTTP Listener
resource "aws_alb_listener" "poc-alb-listener-http" {
  load_balancer_arn = "${aws_alb.poc-alb.arn}"
  port = "80"
  protocol = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.poc-alb-tg.arn}"
    type = "forward"
  }
}

# Application Load Balancer HTTPS Listener
resource "aws_alb_listener" "poc-alb-listener-https" {
  load_balancer_arn = "${aws_alb.poc-alb.arn}"
  port = "443"
  protocol = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-2016-08"
  certificate_arn = "${var.certificate_arn}"
  
  default_action {
    target_group_arn = "${aws_alb_target_group.poc-alb-tg.arn}"
    type = "forward"
  }
}

# Route53 POC domain 
resource "aws_route53_record" "poc" {
  zone_id = "${aws_route53_zone.poc-route53-zone.zone_id}"
  name = "${var.hosted_zone_name}"
  type = "A"
  alias {
    name = "${aws_alb.poc-alb.dns_name}"
    zone_id = "${aws_alb.poc-alb.zone_id}"
    evaluate_target_health = true
  }
}