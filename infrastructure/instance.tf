provider "aws" {
  access_key = "<YOUR_ACCESS_KEY>"
  secret_key = "<YOUR_SECRET_KEY>"
  region     = "ap-southeast-1"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "all" {
  vpc_id = "${data.aws_vpc.default.id}"
}

module "security_group" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "shoppingcart"
  description = "shoppingcart Security group"
  vpc_id      = "${data.aws_vpc.default.id}"
  
  ingress_with_self = [{
    rule = "all-all"
  }]
  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["all-tcp", "all-icmp", "mysql-tcp", "ssh-tcp"]
  egress_rules        = ["all-all"]
}

# kubectl-ready
module "kube_master" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 2.0"

  name = "Kube Master"
  ami  = "ami-0e45ef99a98566a26"

  instance_type = "t3.medium" # slower one is t3.medium faster one is t3.large

  instance_count              = 1
  vpc_security_group_ids      = ["${module.security_group.this_security_group_id}"]
  subnet_id                   = tolist(data.aws_subnet_ids.all.ids)[0]
  associate_public_ip_address = true
  monitoring                  = true

  root_block_device = [
    {
      volume_type = "gp2"
      volume_size = 10
    },
  ]

  key_name = "shoppingcart_key"
  tags = {
    "Type" = "kubernetes"
  }
}

# kubectl-ready
module "kube_slave" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 2.0"

  name = "RSS App"
  ami  = "ami-0e45ef99a98566a26"

  instance_type = "t3.medium" # slower one is t3.medium faster one is t3.large 

  instance_count              = 2
  vpc_security_group_ids      = ["${module.security_group.this_security_group_id}"]
  subnet_id                   = tolist(data.aws_subnet_ids.all.ids)[0]
  associate_public_ip_address = true
  monitoring                  = true

  root_block_device = [
    {
      volume_type = "gp2"
      volume_size = 10
    },
  ]

  key_name = "shoppingcart_key"
  tags = {
    Type = "kubernetes"
  }
}

module "j_meter" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 2.0"

  name = "j meter"
  ami  = "ami-0907d9e140ac01676"

  instance_type = "t3.medium"

  instance_count              = 1
  vpc_security_group_ids      = ["${module.security_group.this_security_group_id}"]
  subnet_id                   = tolist(data.aws_subnet_ids.all.ids)[0]
  associate_public_ip_address = true
  monitoring                  = false

  root_block_device = [
    {
      volume_type = "gp2"
      volume_size = 10
    },
  ]

  key_name = "shoppingcart_key"
  tags = {
    Type = "jmeter"
  }
}