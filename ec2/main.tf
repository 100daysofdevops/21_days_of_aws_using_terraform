provider "aws" {
  region = "us-west-2"
}

data "aws_availability_zones" "available" {}

data "aws_ami" "centos" {
  owners      = ["679593333241"]
  most_recent = true

  filter {
    name   = "name"
    values = ["CentOS Linux 7 x86_64 HVM EBS *"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

resource "aws_key_pair" "mytest-key" {
  key_name   = "my-test-terraform-key-new1"
  public_key = "${file(var.my_public_key)}"
}

data "template_file" "init" {
  template = "${file("${path.module}/userdata.tpl")}"
}

resource "aws_instance" "my-test-instance" {
  count                  = 2
  ami                    = "${data.aws_ami.centos.id}"
  instance_type          = "${var.instance_type}"
  key_name               = "${aws_key_pair.mytest-key.id}"
  vpc_security_group_ids = ["${var.security_group}"]
  subnet_id              = "${element(var.subnets, count.index )}"
  user_data              = "${data.template_file.init.rendered}"

  tags = {
    Name = "my-instance-${count.index + 1}"
  }
}

resource "aws_ebs_volume" "my-test-ebs" {
  count             = 2
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  size              = 1
  type              = "gp2"
}

resource "aws_volume_attachment" "my-vol-attach" {
  count        = 2
  device_name  = "/dev/xvdh"
  instance_id  = "${aws_instance.my-test-instance.*.id[count.index]}"
  volume_id    = "${aws_ebs_volume.my-test-ebs.*.id[count.index]}"
  force_detach = true
}
