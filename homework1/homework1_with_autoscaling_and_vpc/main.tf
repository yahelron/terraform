# Ron Yahel
# tested with Terraform v0.11.14
# this will install an AWS instance, docker & docker-compose.
# docker-compose to run  this flask project & API with mysql DB.
# how to:
# rename this file to main.tf
# create a key --> ssh-keygen -f deployer-key
# copy the public key to public_key insted of the existing one.
# connect with your private key ssh -i "deployer-key.pem" ubuntu@server-url

provider "aws" {
  region = "us-east-1"
  profile = "myaws"
}
# key
#resource "aws_key_pair" "deployer-key" {
#key_name = "deployer-key"
#public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC8J8ChEzOZy3CMV5kwjt25l5gHl3relo030jBn4BCkWgGs4ozELQnSD9Q/SzCe1Fo1S6hLY3SODyQ5sUX6rxxYsQQRGFeIJBc1IOTKpHN5QIZIDNNCXsUUCfApTKyy0kXMsdSS299FfDbqYRH2CCi1clr4J2OnPUOYNfewd4kMaZH6f7lA1wkWY+r6CnNib6msouaTO5DVF8LJPhZWq/4erjCxJxjdjCeexarilUbYMOY9s39bGto+uzUBk4vfWP3plJlvj389qKrXBlmtHk0atYF2BWwGzXNblWnRSgqhVDnxUCWIV1z6kXgTk/V6znICX/sg4F99RnRdv3Fp+4fSHWTdRbmgrSDUkqG9T5IN3y9FiExMNQdIJj+FB94ryQ8MFG2Dh0ZOyUwvGPed9SFunoxMNTIVKEa9n5Zswf3LGJa5R0wHwxXqCIy8bThR691xXFm0AzEEnDXURpc4sTA0Ext0HxAbPiGZMd4CAMiSo/ednRYyOs+SB42W8ZKIZus= yahel@LAPTOP-CJO17IOJ"
#}

locals {
  user_data = <<EOF
  #!/bin/bash
  yum install docker -y
  systemctl enable docker
  systemctl start docker
  docker run -itd -p 80:80 nginx
EOF
}

resource "aws_launch_template" "homework1" {
  name_prefix   = "homework1"

  #block_device_mappings {
  #  device_name = "/dev/xvda1"

  #  ebs {
  #    volume_size = 20
  #  }
  #}
 
  monitoring {
    enabled = true
  }
  image_id      = "ami-065efef2c739d613b"
  key_name      = "deployer-key"
  instance_type = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.instance.id}"]
  user_data  = base64encode(local.user_data)
  
  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "homework1"
    }

}
}



resource "aws_autoscaling_group" "homework1" {
  availability_zones = ["us-east-1a"]
  desired_capacity   = 1
  max_size           = 1
  min_size           = 0

  launch_template {
    id      = aws_launch_template.homework1.id
    version = "$Latest"
  }
}







resource "aws_security_group" "instance" {
  name = "dokuwiki-sg"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Add Output
output "public_ip" {
  value       = "$aws_launch_template.homework1.public_ip.description}"
  description = "The public IP of the web server"
}