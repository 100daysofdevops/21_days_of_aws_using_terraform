provider "aws" {
  region = "us-west-2"
}

data "aws_subnet_ids" "default" {
  vpc_id = "${var.vpc_id}"
}

resource "aws_lb" "my-alb" {
  name               = "my-test-alb"
  load_balancer_type = "application"
  subnets            = "${data.aws_subnet_ids.default.ids}"
  security_groups = ["${aws_security_group.alb.id}"]
}


resource "aws_lb_listener" "my-alb-listner" {
  load_balancer_arn = "${aws_lb.my-alb.arn}"
  port              = 80
  protocol          = "HTTP"

  # By default, return a simple 404 page
  default_action {
    type = "fixed-response"
    target_group_arn = "${aws_lb_target_group.asg.arn}"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }
}


resource "aws_security_group" "alb" {
  name = "my-alb-sg"

  # Allow inbound HTTP requests
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound requests
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb_target_group" "asg" {
  name     = "my-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_launch_configuration" "my-test-launch-config" {
  image_id        = "ami-01ed306a12b7d1c96"
  instance_type   = "t2.micro"
  security_groups = ["${aws_security_group.alb.id}"]


  user_data = <<-EOF
              #!/bin/bash
              yum -y install httpd
              echo "Hello, World" > /var/www/html/index.html
              service httpd start
              chkconfig httpd on
              EOF

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "example" {
  launch_configuration = "${aws_launch_configuration.my-test-launch-config.name}"
  vpc_zone_identifier  = "${data.aws_subnet_ids.default.ids}"

  target_group_arns = ["${aws_lb_target_group.asg.arn}"]
  health_check_type = "ELB"

  min_size = 2
  max_size = 10

  tag {
    key                 = "Name"
    value               = "my-asg-example"
    propagate_at_launch = true
  }
}


resource "aws_lb_listener_rule" "my-alb-listner" {
  listener_arn = "${aws_lb_listener.my-alb-listner.arn}"
  priority     = 100

  condition {
    field  = "path-pattern"
    values = ["*"]
  }

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.asg.arn}"
  }
}