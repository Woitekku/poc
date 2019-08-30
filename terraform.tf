terraform {
    backend "s3" {
        key = "terraform-state/terraform.tfstate"
        bucket = "${var.aws_terraform_state_bucket}"
        region = "${var.aws_region}"
    }
}