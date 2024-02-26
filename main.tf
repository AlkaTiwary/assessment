resource "aws_vpc" "main" {
cidr_block = "10.0.0.0/16"
enable_dns_hostnames = true
enable_dns_support   = true
tags = {
Name = "My VPC1"
}
}
resource "aws_subnet" "public" {
vpc_id            = aws_vpc.main.id
cidr_block        = "10.0.1.0/24"
availability_zone = "us-east-1a" # Replace with your desired AZ
}
resource "aws_subnet" "publib" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b" # Replace with your desired AZ
}
resource "aws_db_subnet_group" "new_subnet_group" {
  name       = "new-subnet-group"
  subnet_ids = [aws_subnet.public.id, aws_subnet.publib.id] # Add the IDs of your default subnets here
}
resource "aws_internet_gateway" "gw" {
vpc_id = aws_vpc.main.id

tags = {
Name = "Internet Gateway"
}
}
resource "aws_route_table" "public_route_table" {
vpc_id = aws_vpc.main.id

route {
cidr_block = "0.0.0.0/0"
gateway_id = aws_internet_gateway.gw.id
}

tags = {
Name = "Public Route Table"
}
}
resource "aws_route_table_association" "first" {
subnet_id         = aws_subnet.public.id
route_table_id    = aws_route_table.public_route_table.id
}
resource "aws_route_table_association" "second" {
  subnet_id      = aws_subnet.publib.id
  route_table_id = aws_route_table.public_route_table.id
}
resource "aws_security_group" "ssh" {
name = "SSH"
vpc_id = aws_vpc.main.id

ingress {
from_port = 3306
to_port = 3306
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"] # Restrict this for production environments
}

egress {
from_port = 0
to_port = 0
protocol = "-1"
cidr_blocks = ["0.0.0.0/0"]
}

tags = {
Name = "SSH Security Group"
}
}

resource "aws_instance" "webserver" {
ami           = "ami-0b0ea68c435eb488d" 
instance_type = "t2.micro" 
vpc_security_group_ids = [aws_security_group.ssh.id]
subnet_id = aws_subnet.public.id
associate_public_ip_address = true
key_name = "tf_key"
tags = {
Name = "Web Server"
}
}
resource "aws_db_instance" "RDS" {
  identifier = "db1"
  storage_type = "gp2"
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  username               = "terra"
  password               = "terra123"
  port                   = 3306
  vpc_security_group_ids = [aws_security_group.ssh.id]
  publicly_accessible    = true
  db_subnet_group_name   = aws_db_subnet_group.new_subnet_group.name
  multi_az = false
  skip_final_snapshot = true

  tags = {
    Name = "db1"
    Env  = "Dev/Test"
  }
}

output "public_ip" {
value = aws_instance.webserver.public_ip
}