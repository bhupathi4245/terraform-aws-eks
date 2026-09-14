resource "aws_instance" "bastion" {
    ami = local.ami_id # Replace with your desired AMI ID
    instance_type = "t3.micro"
    vpc_security_group_ids = [local.bastion_sg_id]
    subnet_id = local.public_subnet_id # Assuming the first public subnet is used.. derived in locals

    # need more for terraform
    root_block_device {
      volume_size = 50
      volume_type = "gp3"   # or "gp2", depending on your performance
    }

    tags = merge(
        local.common_tags,
        {           
            Name = "${var.project}-${var.environment}-bastion"
        }
    )   
}