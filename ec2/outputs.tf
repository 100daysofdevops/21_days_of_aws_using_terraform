output "server_id" {
  value = "${join(",",aws_instance.my-test-instance.*.id)}"
}

output "server_ip" {
  value = "${join(",",aws_instance.my-test-instance.*.public_ip)}"
}