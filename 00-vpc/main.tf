module "vpc" {
    # source = "../../terraform-aws-vpc"
    source = "git::https://github.com/bhupathi4245/terraform-aws-vpc.git?ref=main"
    project = var.project
    environment = var.environment
    public_subnet_cidrs = var.public_subnet_cidrs
    private_subnet_cidrs = var.private_subnet_cidrs
    database_subnet_cidrs = var.database_subnet_cidrs

    is_peering_requried = true
}

/* output "vpc_ids" {
    value = module.vpc.public_subnet_ids
} */