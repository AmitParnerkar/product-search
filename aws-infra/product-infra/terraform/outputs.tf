output "natIP" {
  value = aws_instance.nat.public_ip
}

output "private_subnet_id" {
  value = aws_subnet.private.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}
output "security_web_id" {
  value = aws_security_group.web.id
}
output "common_security_group_id" {
  value = aws_security_group.common.id
}

output "deployer_key_name" {
  value = aws_key_pair.deployer.key_name
}