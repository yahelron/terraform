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
resource "aws_key_pair" "deployer-key" {
key_name = "deployer-key"
public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC8J8ChEzOZy3CMV5kwjt25l5gHl3relo030jBn4BCkWgGs4ozELQnSD9Q/SzCe1Fo1S6hLY3SODyQ5sUX6rxxYsQQRGFeIJBc1IOTKpHN5QIZIDNNCXsUUCfApTKyy0kXMsdSS299FfDbqYRH2CCi1clr4J2OnPUOYNfewd4kMaZH6f7lA1wkWY+r6CnNib6msouaTO5DVF8LJPhZWq/4erjCxJxjdjCeexarilUbYMOY9s39bGto+uzUBk4vfWP3plJlvj389qKrXBlmtHk0atYF2BWwGzXNblWnRSgqhVDnxUCWIV1z6kXgTk/V6znICX/sg4F99RnRdv3Fp+4fSHWTdRbmgrSDUkqG9T5IN3y9FiExMNQdIJj+FB94ryQ8MFG2Dh0ZOyUwvGPed9SFunoxMNTIVKEa9n5Zswf3LGJa5R0wHwxXqCIy8bThR691xXFm0AzEEnDXURpc4sTA0Ext0HxAbPiGZMd4CAMiSo/ednRYyOs+SB42W8ZKIZus= yahel@LAPTOP-CJO17IOJ"
}

# Simple Web Server
resource "aws_instance" "homework1" {
  ami = "ami-065efef2c739d613b"
  instance_type = "t2.micro"
  key_name = "deployer-key"
  vpc_security_group_ids = ["${aws_security_group.instance.id}"]
  user_data = <<-EOF
#!/bin/bash
yum install docker -y
systemctl enable docker
systemctl start docker
docker run -itd -p 80:80 nginx
              EOF
  
  tags = {
    Name = "homework1"
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
  value       = "${aws_instance.homework1.public_ip}"
  description = "The public IP of the web server"
}