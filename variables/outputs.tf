output "terra-inst1_ip_addr" {
  value = aws_instance.terra-inst1.public_ip
}

output "instance_2_ip_addr" {
  value = aws_instance.terra-inst2.public_ip
}

output "db_instance_addr" {
  value = aws_db_instance.db_instance.address
}