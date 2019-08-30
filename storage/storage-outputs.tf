### storage/outputs.tf

output "poc_bucket" {
    value = "${aws_s3_bucket.poc-bucket}"
}