output "alb_dns_name" {
  value = "${aws_lb.my-alb.dns_name}"
}