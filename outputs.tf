output "jumpHostInstanceId" {
  description = "The ID of the instance"
  value       = aws_instance.my_instance.id
}

output "jumpHostPublicIp" {
  description = "The public IP address of the instance"
  value       = aws_instance.my_instance.public_ip
}

output "jumpHostPrivateIp" {
  description = "The private IP address of the instance"
  value       = aws_instance.my_instance.private_ip
}

output "jumpHostPublicDns" {
  description = "The public DNS name of the instance"
  value       = aws_instance.my_instance.public_dns
}

output "jumpHostPrivateDns" {
  description = "The private DNS name of the instance"
  value       = aws_instance.my_instance.private_dns
}

output "jumpHostSshPrivateKey" {
  value     = aws_ssm_parameter.ssh_private_key.arn
}

output "jumpHostUser" {
  value = "ec2-user"
}
