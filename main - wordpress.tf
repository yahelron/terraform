# Ron Yahel
# tested with Terraform v0.11.14
# this will install an AWS instance, docker & docker-compose.
# docker-compose to run  wordpress with mysql DB.
# how to:
# rename this file to main.tf
# create a key --> ssh-keygen -f deployer-key
# copy the public key to public_key insted of the existing one.
# connect with your private key ssh -i "deployer-key.pem" ubuntu@server-url
provider "aws" {
  region = "eu-central-1"
}
# key
resource "aws_key_pair" "deployer-key" {
key_name = "deployer-key"
public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCaIxppvGeLiySE8SJ958yZ63dXvtVbmw7Y83ZHq5YgS4ACmFEnbrgPm/e++ws+le9S8pw+KFEnZqLFwLId39LZNhamLK7U4fMJOCLOASiCQseVd/L5bjQT8pvNxqZQxMVBUPuDtsbwpy21QElMxDbksOaJdS90ZntStjW7tZpau+3wfXyYE0208ao9cBcsOF50/I6GXOpRvrN6n4Ag7kvjqIpmL5/GLQAWHXvS1acwsxBgYPGOv/EMxIyfojZpsHnQpslJJ5b0hrSlYdx/Pn9WqcWrSmFEU1jslWFYoo4awx/vgTRMoh1jOhWmo8v0WxM7jKKFmOHsh7+cZ56Uw9w9 yahel@HITAN-Yahel"
}

# Simple Web Server
resource "aws_instance" "example" {
  ami           = "ami-0cc0a36f626a4fdf5"
  instance_type = "t2.micro"
  key_name = "deployer-key"
  vpc_security_group_ids = ["${aws_security_group.instance.id}"]
  user_data = <<-EOF
              #!/bin/bash
              sudo curl -L https://github.com/docker/compose/releases/download/1.21.2/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
              sudo chmod +x /usr/local/bin/docker-compose
              sudo apt update -y
              sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
              curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
              sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
              sudo apt update -y
              apt-cache policy docker-ce
              sudo apt install -y docker-ce
              wget https://raw.githubusercontent.com/yahelron/terraform/master/docker-compose-wordpress.yml
              sudo docker-compose -f docker-compose-wordpress.yml up &
              EOF
  
  tags = {
    Name = "terraform-example"
  }
}

resource "aws_security_group" "instance" {
  name = "terraform-example-instance"
  ingress {
    from_port   = 8080
    to_port     = 8080
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
  value       = "${aws_instance.example.public_ip}"
  description = "The public IP of the web server"
}