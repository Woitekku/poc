aws_profile = "cloudificationpoc"
aws_region = "eu-west-1"
aws_terraform_state_bucket = "cloudificationpoc-12345"
public_key_path = "id_rsa.pub"
hosted_zone_name = "poc.ging3rlab.com"
delegation_set = "NFQ8LO6Q762N"
vpc_cidr = "10.0.0.0/16"
accessip = "0.0.0.0/0"
database_name = "pocrds"
database_username = "pocrds"
ami = "ami-ebd02392"
instance_type = "t2.micro"
asg_ec2_min_size = 3
asg_ec2_max_size = 5
certificate_arn = "arn:aws:acm:eu-west-1:040136271453:certificate/74e0dc47-160a-491e-9acd-f7965ec32ce5"
health_check_path = "/route53_health_check"
bastion_hostname = "bastion"