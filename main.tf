module "vpc" {
  source  = "app.terraform.io/propassig/vpc/aws"
  version = "3.14.1"

  name = "${var.NAME}-vpc"
  cidr = "10.0.0.0/16"

  enable_dns_support   = true
  enable_dns_hostnames = true

  azs             = ["${var.AWS_REGION}a"]
  private_subnets = ["10.0.1.0/24"]
  public_subnets  = ["10.0.101.0/24"]

}

module "security-group" {
  source  = "app.terraform.io/propassig/security-group/aws"
  version = "4.9.0"

  name        = "${var.NAME}-sg"
  description = "Security group for EC2 instance"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = []
  egress_rules        = ["all-all"]

}

# Define policy ARNs as list
variable iam_policy_arn {
  description = "IAM Policy to be attached to role"
  type = list(string)
  default = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore", "arn:aws:iam::aws:policy/AmazonS3FullAccess"]
}

resource "aws_iam_instance_profile" "magic_profile" {
name = "magic_profile"
role = aws_iam_role.magic_role.name
}

resource "aws_iam_role" "magic_role" {
name        = "magic-role"
description = "Connect to EC2 and let EC2 write to S3"
assume_role_policy = <<EOF
{
"Version": "2012-10-17",
"Statement": {
"Effect": "Allow",
"Principal": {"Service": "ec2.amazonaws.com"},
"Action": "sts:AssumeRole"
}
}
EOF
}

# Then parse through the list using count
resource "aws_iam_role_policy_attachment" "role-policy-attachment" {
  role       = aws_iam_role.magic_role.name
  count      = "${length(var.iam_policy_arn)}"
  policy_arn = "${var.iam_policy_arn[count.index]}"
}


resource "aws_iam_role_policy_attachment" "ssm_policy" {
 role       = aws_iam_role.magic_role.name
 policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
 }

  resource "aws_iam_role_policy_attachment" "s3_policy" {
  role       = aws_iam_role.magic_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
 }