resource "aws_elb" "elb" {
  name = "yahel-bookshelf"
  listener {
    instance_port     = 8080
    instance_protocol = "HTTP"
    lb_port           = 80
    lb_protocol       = "HTTP"
  }
  subnets         = data.aws_subnet_ids.subnets.ids
  security_groups = [aws_security_group.book-elb.id, data.aws_security_group.default-sg.id]
}

resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.asg.id
  elb                    = aws_elb.elb.id
}

output "dns_name" {
  value       = "${aws_elb.elb.dns_name}"
  description = "The public IP of the web server"
}
