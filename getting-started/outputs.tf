output "instance_id"
{
description = " Instance ID of the instance"
value     = "${aws_instance.demo.id}"
}

output "instance_privateip"
{
description = " Instance ID of the instance"
value     = "${aws_instance.demo.private_ip}"
}
output "instance_publicip"
{
description = " Instance ID of the instance"
value     = "${aws_instance.demo.public_ip}"
}
