output "alb_dns_name" {
  value = "${aws_lb.my-aws-alb.dns_name}"
}
