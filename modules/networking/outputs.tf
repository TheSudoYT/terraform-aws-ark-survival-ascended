output "vpc_id" {
  value = aws_vpc.ark_vpc.id
}

output "subnet_id" {
  value = aws_subnet.ark_subnet.id
}

output "security_group_id" {
  value = aws_security_group.ark_security_group.id
}