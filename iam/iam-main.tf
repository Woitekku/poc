### iam/main.tf

# IAM access profile to S3
resource "aws_iam_instance_profile" "poc-s3-access-profile" {
  name = "soc-s3-access-profile"
  role = "${aws_iam_role.poc-s3-access-role.name}"
}
  
# IAM access policy to S3
resource "aws_iam_role_policy" "poc-s3-access-policy" {
  name = "poc-s3-access-policy"
  role = "${aws_iam_role.poc-s3-access-role.id}"
  
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:ListBucket"],
      "Resource": ["arn:aws:s3:::${var.poc_bucket.id}"]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject"
      ],
      "Resource": ["arn:aws:s3:::${var.poc_bucket.id}/*"]
    }
  ]
}
EOF
}

# IAM access role to S3
resource "aws_iam_role" "poc-s3-access-role" {
  name = "poc-s3-access-role"
  
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
              "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

# S3 endpoint for private access
resource "aws_vpc_endpoint" "poc-private-s3-endpoint" {
    vpc_id = "${var.poc_vpc.id}"
    service_name = "com.amazonaws.${var.region}.s3"
    
    route_table_ids = ["${var.poc_prv_rt}"]
    
    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "*",
            "Effect": "Allow",
            "Resource": "*",
            "Principal": "*"
        }
    ]
}
EOF

    tags = {
        Name = "poc-private-s3-endpoint"
    }
}