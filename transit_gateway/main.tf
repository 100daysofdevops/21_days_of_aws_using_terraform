provider "aws" {
  region = "us-west-2"
}

resource "aws_ec2_transit_gateway" "my-test-tgw" {
  description                     = "my-test-transit-gateway"
  amazon_side_asn                 = 64512
  auto_accept_shared_attachments  = "disable"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
  dns_support                     = "enable"
  vpn_ecmp_support                = "enable"

  tags = {
    Name = "my-test-transit-gateway"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "my-test-transit-gateway-attachment" {
  transit_gateway_id = "${aws_ec2_transit_gateway.my-test-tgw.id}"
  vpc_id             = "${var.vpc_id}"
  dns_support        = "enable"

  subnet_ids = [
    "${var.public_subnet1}",
    "${var.public_subnet2}",
  ]

  tags =  {
    Name = "my-test-tgw-vpc-attachment"
  }
}
