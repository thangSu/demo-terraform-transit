resource "aws_eip" "ip" {
    vpc = true
    tags ={
      Name = "elasticIP"
    }
}
resource "aws_nat_gateway" "nat" {
    allocation_id = aws_eip.ip.id
    subnet_id = aws_subnet.subnet["Egress VPC - AZ1"].id
    tags = {
      "Name" = "Nat-subnet Ingress VPC "
    }
}