
# create 3 vpc
resource "aws_vpc" "vpc" {
    for_each = local.vpcs
    cidr_block = each.value   
    tags = {
        "Name" = "${each.key}"
    }
}
# create 2 subnet in 2 different AZ for each vpc
resource "aws_subnet" "subnet"{
    for_each = local.subnets
    vpc_id = each.value.vpc_id
    cidr_block = each.value.cidr_block
    availability_zone = each.value.availability_zone
    tags = {
      "Name" = "${each.key}"
    }

}
#create transit gateway
resource "aws_ec2_transit_gateway" "transit" {
    tags = {
      "Name" = "Transit_gateway"
    }
}
resource "aws_ec2_transit_gateway_vpc_attachment" "tgva1" {
  subnet_ids = [ aws_subnet.subnet["App VPC - AZ1"].id,aws_subnet.subnet["App VPC - AZ2"].id ]
  transit_gateway_id = aws_ec2_transit_gateway.transit.id
  vpc_id = aws_vpc.vpc["App VPC"].id
  tags = {
    "Name" = "App"
  }
}
resource "aws_ec2_transit_gateway_vpc_attachment" "tgva2" {
  subnet_ids = [ aws_subnet.subnet["Ingress VPC - AZ1"].id,aws_subnet.subnet["Ingress VPC - AZ2"].id ]
  transit_gateway_id = aws_ec2_transit_gateway.transit.id
  vpc_id = aws_vpc.vpc["Ingress VPC"].id
    tags = {
    "Name" = "Ingress"
  }
}
resource "aws_ec2_transit_gateway_vpc_attachment" "tgva3" {
  subnet_ids = [ aws_subnet.subnet["Egress VPC - AZ2"].id,aws_subnet.subnet["Egress VPC - AZ1"].id ]
  transit_gateway_id = aws_ec2_transit_gateway.transit.id
  vpc_id = aws_vpc.vpc["Egress VPC"].id
      tags = {
    "Name" = "Egress"
  }
}
# internet gateway
resource "aws_internet_gateway" "ig1" {
    for_each = local.internet_gateway
    vpc_id = aws_vpc.vpc["${each.key}"].id
    tags = {
      "Name" = "${each.value}"
    }
}
resource "aws_route_table" "rtb" {
    vpc_id = aws_vpc.vpc["Ingress VPC"].id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.ig1["Ingress VPC"].id
    }
    route {
       cidr_block = "10.1.0.0/16"
        transit_gateway_id = aws_ec2_transit_gateway.transit.id
    }
    tags = {
      "Name" = "Ingress VPC Route Table"
    }
}
# route table
resource "aws_route_table" "rta" {
    vpc_id = aws_vpc.vpc["App VPC"].id
    route {
        cidr_block = "0.0.0.0/0"
        transit_gateway_id = aws_ec2_transit_gateway.transit.id
    }
    tags = {
      "Name" = "App VPC Route Table"
    }
}
resource "aws_route_table" "rtc" {
    vpc_id = aws_vpc.vpc["Egress VPC"].id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.ig1["Egress VPC"].id
    }
    route {
        cidr_block = "10.1.0.0/16"
        transit_gateway_id = aws_ec2_transit_gateway.transit.id
    }
    tags = {
      "Name" = "Egress VPC Route Table"
    }
}
resource "aws_ec2_transit_gateway_route_table" "association_default_route_table" {
  transit_gateway_id = aws_ec2_transit_gateway.transit.id
}

# TGW Route Table
resource "aws_ec2_transit_gateway_route" "tgw_default_route" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgva3.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway.tgw.association_default_route_table_id
}
resource "aws_route_table" "rt_nat" {
  vpc_id = aws_vpc.vpc["Egress VPC"].id
  route{
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
}
resource "aws_route_table_association" "rt1" {
    subnet_id = aws_subnet.subnet["Ingress VPC - AZ1"].id
    route_table_id = aws_route_table.rtb.id
}
resource "aws_route_table_association" "rt2" {
    subnet_id = aws_subnet.subnet["Egress VPC - AZ1"].id
    route_table_id = aws_route_table.rtc.id
}
resource "aws_route_table_association" "rt3" {
    subnet_id = aws_subnet.subnet["App VPC - AZ1"].id
    route_table_id = aws_route_table.rta.id
}
resource "aws_route_table_association" "rtb_nat" {
  subnet_id = aws_subnet.subnet["Egress VPC - AZ2"].id
  route_table_id = aws_route_table.rt_nat.id
}
