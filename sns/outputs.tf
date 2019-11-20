output "sns_arn" {
  value = "${aws_sns_topic.my-test-alarm.arn}"
}
