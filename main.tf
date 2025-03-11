# main.tf

module "eks-vpc" {
  source = "./modules/vpc"

  cidr_block  = "10.0.0.0/16"
  vpc_prefix  = "eks-sandbox"
  az_num      = 2
  nat_enabled = false
}

#module "eks-cluster" {
#  source = "./modules/eks"
#}
