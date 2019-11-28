provider "aws" {
  region = "us-west-2"
}

module "vpc" {
  source          = "./vpc"
  vpc_cidr        = "10.0.0.0/16"
  public_cidrs    = ["10.0.1.0/24", "10.0.2.0/24"]
  private_cidrs   = ["10.0.3.0/24", "10.0.4.0/24"]
  transit_gateway = "${module.transit_gateway.transit_gateway}"
}

module "ec2" {
  source         = "./ec2"
  my_public_key  = "/tmp/id_rsa.pub"
  instance_type  = "t2.micro"
  security_group = "${module.vpc.security_group}"
  subnets        = "${module.vpc.public_subnets}"
}

module "alb" {
  source = "./alb"
  vpc_id = "${module.vpc.vpc_id}"

  /*  instance1_id = "${module.ec2.instance1_id}"
      instance2_id = "${module.ec2.instance2_id}"*/
  subnet1 = "${module.vpc.subnet1}"

  subnet2 = "${module.vpc.subnet2}"
}

module "auto_scaling" {
  source           = "./auto_scaling"
  vpc_id           = "${module.vpc.vpc_id}"
  subnet1          = "${module.vpc.subnet1}"
  subnet2          = "${module.vpc.subnet2}"
  target_group_arn = "${module.alb.alb_target_group_arn}"
}

module "sns_topic" {
  source       = "./sns"
  alarms_email = "plakhera2019@gmail.com"
}

module "cloudwatch" {
  source      = "./cloudwatch"
  sns_topic   = "${module.sns_topic.sns_arn}"
  instance_id = "${module.ec2.instance_id}"
}

module "rds" {
  source      = "./rds"
  db_instance = "db.t2.micro"
  rds_subnet1 = "${module.vpc.private_subnet1}"
  rds_subnet2 = "${module.vpc.private_subnet2}"
  vpc_id      = "${module.vpc.vpc_id}"
}

module "route53" {
  source   = "./route53"
  hostname = ["test1", "test2"]
  arecord  = ["10.0.1.11", "10.0.1.12"]
  vpc_id   = "${module.vpc.vpc_id}"
}

module "iam" {
  source   = "./iam"
  username = ["plakhera1", "prashant", "pankaj"]
}

module "s3" {
  source         = "./s3"
  s3_bucket_name = "21-days-of-aws-using-terraform"
}

module "cloudtrail" {
  source          = "./cloudtrail"
  cloudtrail_name = "my-demo-cloudtrail-terraform"
  s3_bucket_name  = "s3-cloudtrail-bucket-with-terraform-code"
}

module "transit_gateway" {
  source         = "./transit_gateway"
  vpc_id         = "${module.vpc.vpc_id}"
  public_subnet1 = "${module.vpc.subnet1}"
  public_subnet2 = "${module.vpc.subnet2}"
}

module "kms" {
  source   = "./kms"
  user_arn = "${module.iam.aws_iam_user}"
}
