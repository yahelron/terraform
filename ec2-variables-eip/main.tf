
    module "ec2" {
      source                      = "git::https://github.com/clouddrove/terraform-aws-ec2.git?ref=tags/0.12.7"
      name                        = "ec2-instance"
      application                 = "clouddrove"
      environment                 = "test"
      label_order                 = ["environment", "application", "name"]
      instance_count              = 2
      ami                         = "ami-08d658f84a6d84a80"
      instance_type               = "t2.nano"
      monitoring                  = false
      tenancy                     = "default"
      vpc_security_group_ids_list = [module.ssh.security_group_ids, module.http-https.security_group_ids]
      subnet_ids                  = tolist(module.public_subnets.public_subnet_id)
      assign_eip_address          = true
      associate_public_ip_address = true
      instance_profile_enabled    = true
      iam_instance_profile        = module.iam-role.name
      disk_size                   = 8
      ebs_optimized               = false
      ebs_volume_enabled          = true
      ebs_volume_type             = "gp2"
      ebs_volume_size             = 30
      instance_tags               = { "snapshot" = true }
      dns_zone_id                 = "Z1XJD7SSBKXLC1"
      hostname                    = "ec2"
    }