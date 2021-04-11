# terraform_aws_module_example
Using Terraform V12, build a module meant to deploy a web application in AWS

## Usage

~~~
Cloud  provider = "aws" {
  region = "us-west-2"
}

module "vpc" {
  source          = "https://github.com/santanuaich1992/terraform_aws_module_example.git/vpc"
  vpc_cidr        = "10.0.0.0/16"
  public_cidrs    = ["10.0.1.0/24", "10.0.2.0/24"]
  private_cidrs   = ["10.0.3.0/24", "10.0.4.0/24"]
  transit_gateway = "${module.transit_gateway.transit_gateway}"
}

Note : Using VPC we have  secured our environment where we  are  using public subnet for internet access and private subnet for  intranet usage and  using Transit gateway the  overall  network complexity become reduced and it helps to connnect AWS from on prem/local machine securely.

module "ec2" {
  source         = "https://github.com/santanuaich1992/terraform_aws_module_example.git/ec2"
  my_public_key  = "https://github.com/santanuaich1992/terraform_aws_module_example.git/ec2/id_rsa.pub"
  instance_type  = "t2.micro"
  security_group = "${module.vpc.security_group}"
  subnets        = "${module.vpc.public_subnets}"
}

Note : For Web application we used t2.micro ec2 instance type with security group/firewal and subnet using in vpc

module "alb" {
  source = "https://github.com/santanuaich1992/terraform_aws_module_example.git/alb"
  vpc_id = "${module.vpc.vpc_id}"

  /*  instance1_id = "${module.ec2.instance1_id}"
      instance2_id = "${module.ec2.instance2_id}"*/
  subnet1 = "${module.vpc.subnet1}"

  subnet2 = "${module.vpc.subnet2}"
}

Note : We are using Application Load Balancer for Web application at application layer (HTTP/HTTPS) which helps to balance the traffic and we use  auti scaling module to create the target instance group  here Hence we commmented out the instance id declaration here other we can also use that to create the target group instances for ALB.

module "auto_scaling" {
  source           = "https://github.com/santanuaich1992/terraform_aws_module_example.git/auto_scaling"
  vpc_id           = "${module.vpc.vpc_id}"
  subnet1          = "${module.vpc.subnet1}"
  subnet2          = "${module.vpc.subnet2}"
  target_group_arn = "${module.alb.alb_target_group_arn}"
}

Note : It will create scale the instance when utillization become high.

module "sns_topic" {
  source       = "https://github.com/santanuaich1992/terraform_aws_module_example.git/sns"
  alarms_email = "santanudetc@gmail.com"
}
Note  This  will help to get alarm mail when thershold reach to its optimal position

module "cloudwatch" {
  source      = "https://github.com/santanuaich1992/terraform_aws_module_example.git/cloudwatch"
  sns_topic   = "${module.sns_topic.sns_arn}"
  instance_id = "${module.ec2.instance_id}"
}
Note  this  module will  create the Resourse utilization  parameter  which will monitor  the utilization and  ask  SNS to send out mail too see the issue if anything occurs
module "rds" {
  source      = "https://github.com/santanuaich1992/terraform_aws_module_example.git/rds"
  db_instance = "db.t2.micro"
  rds_subnet1 = "${module.vpc.private_subnet1}"
  rds_subnet2 = "${module.vpc.private_subnet2}"
  vpc_id      = "${module.vpc.vpc_id}"
}
Note THis  backend DB will  store the  user data and track record of  Web application usage and we can also retreive details as required and compute them
module "route53" {
  source   = "https://github.com/santanuaich1992/terraform_aws_module_example.git/route53"
  hostname = ["test1", "test2"]
  arecord  = ["10.0.1.11", "10.0.1.12"]
  vpc_id   = "${module.vpc.vpc_id}"
}
Note  this will  create Web URl to access over internet (DNS Record)
module "iam" {
  source   = "https://github.com/santanuaich1992/terraform_aws_module_example.git/iam"
  username = ["suresh", "santanu", "sundar"]
}
Note This will help to provide  user  access as per Roel and Policy
module "s3" {
  source         = "https://github.com/santanuaich1992/terraform_aws_module_example.git/s3"
  s3_bucket_name = "s3-aws-using-terraform"
}
Note it will store archived logs from EBS 
module "cloudtrail" {
  source          = "https://github.com/santanuaich1992/terraform_aws_module_example.git/cloudtrail"
  cloudtrail_name = "my-demo-cloudtrail-terraform"
  s3_bucket_name  = "s3-cloudtrail-bucket-with-terraform-code"
}
Note it will  create different types of  audit logs
module "transit_gateway" {
  source         = "https://github.com/santanuaich1992/terraform_aws_module_example.git/transit_gateway"
  vpc_id         = "${module.vpc.vpc_id}"
  public_subnet1 = "${module.vpc.subnet1}"
  public_subnet2 = "${module.vpc.subnet2}"
}
Note it will help to minimize the  complexity the VPC networking and also help to connect VPC from on prem machine directly
module "kms" {
  source   = "https://github.com/santanuaich1992/terraform_aws_module_example.git/kms"
  user_arn = "${module.iam.aws_iam_user}"
}
Note It will help  to encrypt the data and as per  role providde the key access to read the data.