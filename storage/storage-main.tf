### storage/main.tf

# S3 bucket random id
resource "random_id" "poc-bucket-id" {
    byte_length = 2
}

# S3 bucket
resource "aws_s3_bucket" "poc-bucket" {
    bucket = "poc-${random_id.poc-bucket-id.dec}"
    acl = "private"
    force_destroy = true
    
    tags = {
        Name = "poc-bucket"
    }
}

# Upload application code to the S3
resource "aws_s3_bucket_object" "upload" {
    bucket = "${aws_s3_bucket.poc-bucket.id}"
    key = "springboot-s3-example-0.0.1-SNAPSHOT.jar"
    source = "springboot-s3-example-0.0.1-SNAPSHOT.jar"
}