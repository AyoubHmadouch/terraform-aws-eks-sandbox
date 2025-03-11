terraform {
  backend "s3" {
    bucket  = "tf-s3-backends"
    key     = "terraform-aws-eks-sandbox/terraform.tfstate"
    region  = "eu-west-1"
    encrypt = true
  }
}
