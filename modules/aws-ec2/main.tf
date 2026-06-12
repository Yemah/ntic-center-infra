# Clé SSH pour l'accès Ansible
resource "aws_key_pair" "deployer" {
  key_name   = "ntic-center-deployer-key"
  public_key = file("~/.ssh/id_rsa.pub") 
}

# VPC
resource "aws_vpc" "vpc_abj" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = { Name = "vpc-abidjan" }
}

# Subnet public
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.vpc_abj.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = true
  tags = { Name = "subnet-public-abj" }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc_abj.id
  tags   = { Name = "igw-abidjan" }
}

# Route table
resource "aws_route_table" "rt_public" {
  vpc_id = aws_vpc.vpc_abj.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "rt-public-abj" }
}

resource "aws_route_table_association" "rta" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.rt_public.id
}

# Security Group Web
resource "aws_security_group" "web" {
  name   = "web-abidjan-sg"
  vpc_id = aws_vpc.vpc_abj.id

  ingress {
    from_port   = 80
    to_port     = 80
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
  tags = { Name = "web-abidjan-sg" }
}

# AMI Ubuntu 22.04
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# EC2 Web Abidjan
resource "aws_instance" "web_abj" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public_a.id
  vpc_security_group_ids = [aws_security_group.web.id]
  key_name               = aws_key_pair.deployer.key_name # <-- LIGNE À AJOUTER
  tags = { Name = "web-abidjan" }
}

# RDS MySQL (db.t3.micro = Free Tier)
resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.vpc_abj.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "eu-west-1b"
  map_public_ip_on_launch = true
  tags = { Name = "subnet-public-abj-b" }
}

resource "aws_db_subnet_group" "db_subnet" {
  name       = "db-subnet-abj"
  subnet_ids = [aws_subnet.public_a.id, aws_subnet.public_b.id]
}

resource "aws_db_instance" "mysql_abj" {
  identifier          = "db-abidjan"
  allocated_storage   = 20
  engine              = "mysql"
  engine_version      = "8.0"
  instance_class      = "db.t3.micro"
  db_name             = "nticdb"
  username            = "admin"
  password            = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.db_subnet.name
  vpc_security_group_ids = [aws_security_group.web.id]
  skip_final_snapshot    = true
  tags = { Name = "db-abidjan" }
}