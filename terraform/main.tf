# Provider
provider "aws" {
  region = var.region
}

# VPC 
resource "aws_vpc" "loomi_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "loomi_vpc"
  }
}

# Internet gateway
resource "aws_internet_gateway" "loomi_internet_gateway" {
  vpc_id = aws_vpc.loomi_vpc.id

  tags = {
    Name = "loomi_internet_gateway"
  }
}

## SUBNETS
# Subnet pública
resource "aws_subnet" "loomi_pb_subnet" {
  vpc_id                  = aws_vpc.loomi_vpc.id
  cidr_block              = var.cidr_subnet1
  availability_zone       = var.availability_zone1
  map_public_ip_on_launch = true

  tags = {
    Name = "loomi_pb_subnet"
  }
}

# Subnet privada
resource "aws_subnet" "loomi_pv_subnet" {
  vpc_id                  = aws_vpc.loomi_vpc.id
  cidr_block              = var.cidr_subnet2
  availability_zone       = var.availability_zone2
  map_public_ip_on_launch = false

  tags = {
    Name = "loomi_pb_subnet"
  }
}

# subnet group para o rds
resource "aws_db_subnet_group" "loomi_db_subnet_group" {
  name       = "loomi_db_subnet_group"
  subnet_ids = [aws_subnet.loomi_pv_subnet.id, aws_subnet.loomi_pb_subnet.id]
}

## ROUTE TABLES
# Route table da subnet pública
resource "aws_route_table" "loomi_pb_route_table" {
  vpc_id = aws_vpc.loomi_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.loomi_internet_gateway.id
  }

  tags = {
    Name = "loomi_pb_route_table"
  }
}

# Route table da subnet privada
resource "aws_route_table" "loomi_pv_route_table" {
  vpc_id = aws_vpc.loomi_vpc.id

  tags = {
    Name = "loomi_pv_route_table"
  }
}

## ROUTE TABLES ASSOCIATIONS 
# Assosiação da subnet pública com a route table pública
resource "aws_route_table_association" "loomi_pb_route_table_assosiation" {
  subnet_id      = aws_subnet.loomi_pb_subnet.id
  route_table_id = aws_route_table.loomi_pb_route_table.id
}

# Assosiação da subnet privada com a route table privada
resource "aws_route_table_association" "loomi_pv_route_table_assosiation" {
  subnet_id      = aws_subnet.loomi_pv_subnet.id
  route_table_id = aws_route_table.loomi_pv_route_table.id
}

## SECURITY GROUPS
# Security group da subnet pública
resource "aws_security_group" "loomi_public_sg" {
  name = "loomi_public_sg"
  vpc_id      = aws_vpc.loomi_vpc.id

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "allow ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "allow http"
    from_port   = 0
    to_port     = 80
    protocol    = "tcp"
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "permit all"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }

  tags = {
    Name = "loomi_public_sg"
  }
}

# RDS security group
resource "aws_security_group" "loomi_rds" {
  name        = "loomi_rds"
  description = "Allow inbound/outbound traffic"
  vpc_id      = aws_vpc.loomi_vpc.id

  ingress {
    cidr_blocks = ["107.0.0.0/20"]
    description = "allow port 5432 on local connections"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
  }
}

# Elastic ip
resource "aws_eip" "loomi_eip" {
  instance = aws_instance.loomi_ec2_instance.id
  tags = {
    Name = "loomi_eip"
  }
}

# Definir ami usada na maquina EC2 (Ubuntu)
data "aws_ami" "ubuntu" {
  most_recent = "true"
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

# ssh key
resource "aws_key_pair" "loomi_ssh" {
  key_name   = "loomi-ssh"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCoMzt0UuHRT0EjXAhjwyTyrMiqwKoDH928n6IQZApafzSeBxplMCFKyw+QbMado0D/W2HpeIg0UWk4jFCi0ERSRESsKe6Y7SYXFuRO4tcYszRX1p9057TgxYocxdN12XYeez25Zj92uzWugDSpP5Qu0ueIFUQxkWQg48blAkQv5QKx78FCM4rfCfckNpT68zhj6PPx2OWFr3Sfi/PEBLUGAsOQmHv21kO6dfG3XwSOlz4XQA8gk9/iU+G/7QAFg/1qyRKzK4gz5jThVpekVpgN3OlmVpweO/5CFk0DEbErO0g3ZVff9OPFcl8XgppRtyo0UaXILIPZlsQSD+drDTMAV6WvZmYGH/yVh2oqgTxMzPLCh4yh/BPAt7DsGgFXuNQ7AZGHA4dgHsbFM13AflGPulNle59RPJMH0uDfgkz3MYEzdL2W7p65pR38WfC5DU6V/M2NwrfWOeKlzcW6y/UHB+uY5u971wYUof0rqiOSsOUldYs5ICw6EvGslATYJKk= joaopedroduarte@Joaos-MacBook-Air.local"
}

# EC2
resource "aws_instance" "loomi_ec2_instance" {
  ami             = data.aws_ami.ubuntu.id
  instance_type   = "t2.micro"
  key_name        = aws_key_pair.loomi_ssh.id
  subnet_id       = aws_subnet.loomi_pb_subnet.id
  security_groups = [aws_security_group.loomi_public_sg.id]

  user_data  = file("./setup.sh")

  depends_on = [aws_db_instance.loomi_rds]

  tags = {
    Name = "loomi_ec2_instance"
  }
}

# RDS
resource "aws_db_instance" "loomi_rds" {
  identifier             = "loomi-rds"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  engine                 = "postgres"
  engine_version         = "16.3"
  skip_final_snapshot    = true
  publicly_accessible    = true
  vpc_security_group_ids = [aws_security_group.loomi_rds.id]
  username               = "loomi"
  password               = var.db_password

  db_subnet_group_name = aws_db_subnet_group.loomi_db_subnet_group.id

  tags = {
    Name = "loomi_rds"
  }
}
