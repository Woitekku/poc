### iam_instance_profile/outputs.tf

output "poc_s3_access_profile" {
    value = "${aws_iam_instance_profile.poc-s3-access-profile}"
}