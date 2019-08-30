terraform {
    backend "s3" {
        key = "terraform-state/terraform.tfstate"
        bucket = "cloudificationpoc-12345"
        region = "eu-west-1"
    }
}