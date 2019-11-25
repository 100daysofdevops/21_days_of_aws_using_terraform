output "transit_gateway" {
  value = "${aws_ec2_transit_gateway.my-test-tgw.id}"
}
