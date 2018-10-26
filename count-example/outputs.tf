# Outputs.tf

output "instance_IP" {
  description = " Public IP of the instance"
  value       = "${aws_instance.web-nginx.*.public_ip}"
}

output "address" {
  value = "Instances: ${element(aws_instance.web-nginx.*.id, 0)}"
}
