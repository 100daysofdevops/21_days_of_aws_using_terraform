provider "aws" {
  region = "us-west-2"
}

resource "aws_db_instance" "my-test-sql" {
  instance_class          = "${var.db_instance}"
  engine                  = "mysql"
  engine_version          = "5.7"
  multi_az                = true
  storage_type            = "gp2"
  allocated_storage       = 20
  name                    = "mytestrds"
  username                = "admin"
  password                = "admin123"
  apply_immediately       = "true"
  backup_retention_period = 10
  backup_window           = "09:46-10:16"
  db_subnet_group_name    = "${aws_db_subnet_group.my-rds-db-subnet.name}"
  vpc_security_group_ids  = ["${aws_security_group.my-rds-sg.id}"]
}

resource "aws_db_subnet_group" "my-rds-db-subnet" {
  name       = "my-rds-db-subnet"
  subnet_ids = ["${var.rds_subnet1}", "${var.rds_subnet2}"]
}

resource "aws_security_group" "my-rds-sg" {
  name   = "my-rds-sg"
  vpc_id = "${var.vpc_id}"
}

resource "aws_security_group_rule" "my-rds-sg-rule" {
  from_port         = 3306
  protocol          = "tcp"
  security_group_id = "${aws_security_group.my-rds-sg.id}"
  to_port           = 3306
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "outbound_rule" {
  from_port         = 0
  protocol          = "-1"
  security_group_id = "${aws_security_group.my-rds-sg.id}"
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}

/*
data "aws_kms_secret" "rds" {
  secret {
    name = "db-password"
    payload = "AQICAHibS2rwth4UleeAxsSEfxgwqkPtD0jzkRM/Ez91Y7cbvwEHP2YRcuplZp/H7GqmIuXVAAAAZjBkBgkqhkiG9w0BBwagVzBVAgEAMFAGCSqGSIb3DQEHATAeBglghkgBZQMEAS4wEQQMps5PwT/x3nCnBMfTAgEQgCNd+Y6q9KBZbIX8JZlqP7EDErQLuaBLh6mKaYBz+5blxWstwQ=="
  }
}
*/

