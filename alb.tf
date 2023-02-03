resource "aws_lb_target_group" "test_group" {
  health_check {
    interval = 10
    path = "/"
    protocol = "HTTP"
    timeout = 5
    healthy_threshold = 5
    unhealthy_threshold = 2
  }
  name = "testApp"
  port = 80
  protocol = "HTTP"
  target_type = "instance"
  vpc_id = aws_vpc.vpc["App VPC"].id
}
//sgs
resource "aws_security_group" "lb_sg" {
    vpc_id = aws_vpc.vpc["App VPC"].id
    name = "LB - SG"
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [ "10.2.0.0/16" ]
    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = [ "10.2.0.0/16" ]
    }
    ingress {
        from_port = 8
        to_port = 0
        protocol = "icmp"
        cidr_blocks = [ "10.2.0.0/16" ]
    }
    egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    }
}

// create lb
resource "aws_lb" "test_lb" {
  name               = "test-lb"
  internal           = true
  ip_address_type = "ipv4"
  load_balancer_type = "application"
  security_groups = [ aws_security_group.lb_sg.id  ]
  subnets            = [aws_subnet.subnet["App VPC - AZ1"].id, aws_subnet.subnet["App VPC - AZ2"].id]
  tags = {
    Environment = "test"
  }
}
// create listener
resource "aws_lb_listener" "test_listener" {
  load_balancer_arn = aws_lb.test_lb.arn
  port = 80
  protocol = "HTTP"
  default_action {
    target_group_arn = aws_lb_target_group.test_group.arn
    type = "forward"
  }
}
resource "aws_lb_target_group_attachment" "test_target1" {
    count =2
    target_group_arn = aws_lb_target_group.test_group.arn
    target_id = aws_instance.instance1[count.index].id
}