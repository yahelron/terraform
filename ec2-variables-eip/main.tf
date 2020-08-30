provider "aws" {
  region = "us-east-1"

}


resource "aws_instance" "web" {
  ami = "ami-0b898040803850657"
  instance_type = "t2.micro"

    root_block_device {
    volume_size = "16"
  }
  tags = {
    Name = "mydev ${var.server_name} "
    Owner = "IT"
  }
//  user_data = file("../../init.sh")
}
resource "aws_eip" "myip" {
  instance = aws_instance.web.id
  vpc      = true
}



output "public_dns" {
  value = aws_instance.web.public_dns
}

variable "server_name" {
  type = string
  description = "this will be the value for tag name"
}

locals {
  init_sh = "echo hello world!"
}