output "instance_id" {
  value = "${element(aws_instance.my-test-instance.*.id, 1)}"
}

/*
output "instance2_id" {
  value = "${element(aws_instance.my-test-instance.*.id, 2)}"
}
*/

output "server_ip" {
  value = "${join(",",aws_instance.my-test-instance.*.public_ip)}"
}

/*
output "instance_id" {
  value = "${aws_instance.my-test-instance.*.id}"
}*/

