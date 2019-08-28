output "master" {
  value       = aws_instance.master.public_ip
  description = "The IP for master"
}

output "nodes" {
  value       = aws_instance.node[*].public_ip
  description = "The IPs for all nodes"
}