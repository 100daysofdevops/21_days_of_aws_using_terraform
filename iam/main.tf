provider "aws" {
  region = "us-west-2"
}

resource "aws_iam_user" "my-test-user" {
  name  = "${element(var.username,count.index)}"
  count = "${length(var.username)}"
}

resource "aws_iam_role_policy" "my-test-policy" {
  name = "my-test-iam-policy"
  role = "${aws_iam_role.my-test-iam-role.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "cloudwatch:PutMetricData",
                "ec2:DescribeTags",
                "logs:PutLogEvents",
                "logs:DescribeLogStreams",
                "logs:DescribeLogGroups",
                "logs:CreateLogStream",
                "logs:CreateLogGroup"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role" "my-test-iam-role" {
  name = "my-test-iam-role"

  assume_role_policy = <<EOF
{
"Version": "2012-10-17",
"Statement": [
{
"Action": "sts:AssumeRole",
"Principal": {
 "Service": "ec2.amazonaws.com"
},
"Effect": "Allow"
}
]
}
EOF

  tags = {
    tag-key = "my-test-iam-role"
  }
}

resource "aws_iam_instance_profile" "my-test-iam-instance-profile" {
  name = "my-test-iam-instance-profile"
  role = "${aws_iam_role.my-test-iam-role.name}"
}
