output "public_subnets" {
  value = "${aws_subnet.public_subnet.*.id}"
}

output "security_group" {
  value = "${aws_security_group.test_sg.id}"
}

output "vpc_id" {
  value = "${aws_vpc.main.id}"
}

