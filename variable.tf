locals {
    vpcs={
        "App VPC" = "10.1.0.0/16"
        "Ingress VPC" = "10.2.0.0/16"
        "Egress VPC" = "10.3.0.0/16"
    }
    internet_gateway ={
        "Egress VPC" ="Egress VPC - IGW"
        "Ingress VPC" ="Ingress VPC - IGW"
    }
    subnets={
        "App VPC - AZ1" ={
            vpc_id = aws_vpc.vpc["App VPC"].id
            cidr_block = "10.1.0.0/24"
            availability_zone= "us-east-1a"
        }
        "App VPC - AZ2" ={
            vpc_id = aws_vpc.vpc["App VPC"].id
            cidr_block = "10.1.1.0/24"
            availability_zone= "us-east-1b"
        }
        "Ingress VPC - AZ1" ={
            vpc_id = aws_vpc.vpc["Ingress VPC"].id
            cidr_block = "10.2.0.0/24"
            availability_zone= "us-east-1a"
        }
        "Ingress VPC - AZ2" ={
            vpc_id = aws_vpc.vpc["Ingress VPC"].id
            cidr_block = "10.2.1.0/24"
            availability_zone= "us-east-1b"
        }
        "Egress VPC - AZ1" ={
            vpc_id = aws_vpc.vpc["Egress VPC"].id
            cidr_block = "10.3.0.0/24"
            availability_zone= "us-east-1a"
        }
        "Egress VPC - AZ2" ={
            vpc_id = aws_vpc.vpc["Egress VPC"].id
            cidr_block = "10.3.1.0/24"
            availability_zone= "us-east-1b"
        }
    }
    instances={
        "EC2 App VPC - AZ1" ={
            subnet_id = aws_subnet.subnet["App VPC - AZ1"].id
            vpc= aws_security_group.sg.id
        }
        "EC2 Ingress VPC - AZ1" ={
            subnet_id = aws_subnet.subnet["Ingress VPC - AZ1"].id
            vpc= aws_security_group.sg1.id
        }
        "EC2 Egress VPC - AZ1" ={
            subnet_id = aws_subnet.subnet["Egress VPC - AZ1"].id
            vpc=  aws_security_group.sg2.id
        }
    }
}