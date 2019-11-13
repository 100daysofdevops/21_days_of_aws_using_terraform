provider "aws" {
  region = "us-west-2"
}

resource "aws_security_group" "examplesg" {
  name        = "my-example-sg"
  description = "Allow ssh traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "ec2_instance" {
  ami                    = "ami-01ed306a12b7d1c96"
  instance_type          = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.examplesg.id}"]
  key_name               = "${aws_key_pair.examplekp.id}"

  tags = {
    Name = "my-first-webserver-dev"
  }
}

resource "aws_key_pair" "examplekp" {
  key_name   = "my-example-key"
  public_key = ""
}
