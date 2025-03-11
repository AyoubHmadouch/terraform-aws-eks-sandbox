# modules/vpc/outputs.tf

output "vpc_id" {
  value       = aws_vpc.self.id
  description = "VPC ID"
}

output "public_subnet_ids" {
  value       = values(aws_subnet.public)[*].id
  description = "Public Subnet IDs"
}

output "private_subnet_ids" {
  value       = values(aws_subnet.private)[*].id
  description = "Private Subnet IDs"
}
