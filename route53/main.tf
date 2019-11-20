provider "aws" {
  region = "us-west-2"
}

resource "aws_route53_zone" "my-test-zone" {
  name = "example.com"

  vpc {
    vpc_id = "${var.vpc_id}"
  }
}

resource "aws_route53_record" "my-example-record" {
  count   = "${length(var.hostname)}"
  name    = "${element(var.hostname,count.index )}"
  records = ["${element(var.arecord,count.index )}"]
  zone_id = "${aws_route53_zone.my-test-zone.id}"
  type    = "A"
  ttl     = "300"
}
