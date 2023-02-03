data "aws_ami""ami_linux" {

	most_recent = true
    owners = ["amazon"]
	filter {
	name = "name"
	values = ["amzn2-ami-kernel-5.10-hvm-*-x86_64-gp2"]
	}
	filter {
	name = "virtualization-type"
	values = ["hvm"]
  }
}
resource "aws_security_group" "sg" {
    vpc_id = aws_vpc.vpc["App VPC"].id
    name = "App VPC - SG"
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [ "0.0.0.0/0" ]
    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = [ "0.0.0.0/0" ]
    }
    ingress {
        from_port = 8
        to_port = 0
        protocol = "icmp"
        cidr_blocks = [ "10.1.0.0/16" ]
    }
    egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    }
}
resource "aws_security_group" "sg1" {
    vpc_id = aws_vpc.vpc["Ingress VPC"].id
    name = "Ingress VPC - SG"
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [ "0.0.0.0/0" ]
    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = [ "0.0.0.0/0" ]
    }
    ingress {
        from_port = 8
        to_port = 0
        protocol = "icmp"
        cidr_blocks = [ "10.1.0.0/16" ]
    }
    egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    }
}
resource "aws_security_group" "sg2" {
    vpc_id = aws_vpc.vpc["Egress VPC"].id
    name = "Egress VPC - SG"
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [ "0.0.0.0/0" ]
    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = [ "0.0.0.0/0" ]
    }
    ingress {
        from_port = 8
        to_port = 0
        protocol = "icmp"
        cidr_blocks = [ "10.1.0.0/16" ]
    }
    egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    }
}
resource "aws_instance" "instance" {
    ami = data.aws_ami.ami_linux.id
    instance_type = "t2.micro"
    subnet_id =  aws_subnet.subnet["Ingress VPC - AZ1"].id
    vpc_security_group_ids = [ aws_security_group.sg1.id ]
    associate_public_ip_address = true
    key_name = "thang_hey"
    tags = {
      "Name" = "test-server Ingress VPC"
    }
}
resource "aws_instance" "instance1" {
    count = 2
    ami = data.aws_ami.ami_linux.id
    instance_type = "t2.micro"
    subnet_id =  aws_subnet.subnet["App VPC - AZ1"].id
    vpc_security_group_ids = [ aws_security_group.sg.id ]
    associate_public_ip_address = true
    key_name = "thang_hey"
    iam_instance_profile = aws_iam_instance_profile.nana.name
    tags = {
      "Name" = "server A ${count.index}"
    }
    user_data = file("base.sh")
}
resource "aws_instance" "instance2" {
    ami = data.aws_ami.ami_linux.id
    instance_type = "t2.micro"
    subnet_id =  aws_subnet.subnet["Egress VPC - AZ1"].id
    vpc_security_group_ids = [ aws_security_group.sg2.id ]
    associate_public_ip_address = true
    key_name = "thang_hey"
    iam_instance_profile = aws_iam_instance_profile.nana.name
    tags = {
      "Name" = "Bastion host"
    }
}
resource "aws_instance" "instance3" {
    ami = data.aws_ami.ami_linux.id
    instance_type = "t2.micro"
    subnet_id =  aws_subnet.subnet["Egress VPC - AZ2"].id
    vpc_security_group_ids = [ aws_security_group.sg2.id ]
    associate_public_ip_address = true
    key_name = "thang_hey"
    iam_instance_profile = aws_iam_instance_profile.nana.name
    tags = {
      "Name" = "Private host"
    }
}