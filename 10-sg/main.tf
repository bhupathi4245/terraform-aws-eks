module "ingress_alb" {
    # source = "../../terraform-aws-securitygroup"
    source = "git::https://github.com/bhupathi4245/terraform-aws-securitygroup.git?ref=main"
    project     = var.project
    environment = var.environment

    sg_name = "ingress_alb"
    sg_description = "for ingress alb"
    vpc_id = local.vpc_id
}

module "bastion" {
    # source = "../../terraform-aws-securitygroup"
    source = "git::https://github.com/bhupathi4245/terraform-aws-securitygroup.git?ref=main"
    project     = var.project
    environment = var.environment

    sg_name = var.bastion_sg_name
    sg_description = var.bastion_sg_description
    vpc_id = local.vpc_id
}

module "vpn" {
    # source = "../../terraform-aws-securitygroup"
    source = "git::https://github.com/bhupathi4245/terraform-aws-securitygroup.git?ref=main"
    project     = var.project
    environment = var.environment

    sg_name = "vpn"
    sg_description = "for vpn"
    vpc_id = local.vpc_id
}

module "eks_control_plane" {
    # source = "../../terraform-aws-securitygroup"
    source = "git::https://github.com/bhupathi4245/terraform-aws-securitygroup.git?ref=main"
    project     = var.project
    environment = var.environment

    sg_name = "eks_control_plane"
    sg_description = "for eks_control_plane"
    vpc_id = local.vpc_id
}

module "eks_node" {
    # source = "../../terraform-aws-securitygroup"
    source = "git::https://github.com/bhupathi4245/terraform-aws-securitygroup.git?ref=main"
    project     = var.project
    environment = var.environment

    sg_name = "eks_node"
    sg_description = "for eks_node"
    vpc_id = local.vpc_id
}

# ingress as Frontend ALB - accepting https connections on ports 443 respectively
resource "aws_security_group_rule" "ingress_alb_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.ingress_alb.sg_id
}

# bastion accepting connections from developers laptop
resource "aws_security_group_rule" "bastion_laptop" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.bastion.sg_id
}

#VPN ports 22, 443, 1194, 943 --> from my/developers laptops
resource "aws_security_group_rule" "vpn_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.vpn.sg_id
}

resource "aws_security_group_rule" "vpn_https"{
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.vpn.sg_id
}

resource "aws_security_group_rule" "vpn_1194" {
  type              = "ingress"
  from_port         = 1194
  to_port           = 1194
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.vpn.sg_id
}

resource "aws_security_group_rule" "vpn_943" {
  type              = "ingress"
  from_port         = 943
  to_port           = 943
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.vpn.sg_id
}

# New security grops for EKS control plane and eks nodes for each other (2)
# and also eks nodes and controlplane allowed from bastion host (2)
resource "aws_security_group_rule" "eks_control_plane_from_eks_node" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  source_security_group_id = module.eks_node.sg_id
  security_group_id = module.eks_control_plane.sg_id
}

resource "aws_security_group_rule" "eks_node_from_eks_control_plane" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  source_security_group_id = module.eks_control_plane.sg_id
  security_group_id = module.eks_node.sg_id
}

resource "aws_security_group_rule" "eks_control_plane_from_bastion" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  source_security_group_id = module.bastion.sg_id
  security_group_id = module.eks_control_plane.sg_id
}

resource "aws_security_group_rule" "eks_node_from_bastion" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.bastion.sg_id
  security_group_id = module.eks_node.sg_id
}

# allow all traffic from VPN to EKS nodes
resource "aws_security_group_rule" "eks_node_vpc" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["10.0.0.0/16"]
  security_group_id = module.vpn.sg_id
}