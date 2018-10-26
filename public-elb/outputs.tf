output "nginx_elb_dns" {
  description = " Nginix Web Service DNS NAME"
  value = "${aws_elb.sig-svc.dns_name}"
}
output "nginx_elb_id" {
  description = "Web Service ID"
  value = "${aws_elb.sig-svc.id}"
}
