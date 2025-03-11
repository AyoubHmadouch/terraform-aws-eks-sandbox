# modules/vpc/varibales.tf

variable "cidr_block" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_prefix" {
  description = "VPC name"
  type        = string
  default     = "eks-sandbox"
}

variable "az_num" {
  description = "number of availability zones"
  type        = number
  default     = 2
}

variable "nat_enabled" {
  description = "Enable NAT Gateway"
  type        = bool
  default     = true
}
