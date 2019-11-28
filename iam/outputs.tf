output "aws_iam_user" {
  value = "${aws_iam_user.my-test-user.0.arn}"
}