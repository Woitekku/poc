terraform {
    backend "s3" {
        key = "terraform-state/terraform.tfstate"
        bucket = "cloudificationpoc"
        region = "eu-west-1"
        shared_credentials_file = "./credentials"
    }
}