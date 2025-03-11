variable "project" {
  type        = string
  description = "Project name."
  default     = "EKS-Sandbox"
}

variable "region" {
  type        = string
  description = "AWS region in which the eks will be deployed."
  default     = "eu-west-1"
}

variable "environment" {
  type        = string
  description = "Environment name."
  default     = "dev"
}

# VPC Vars :



# EKS Vars :
