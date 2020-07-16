
provider "aws" {
  region     = "ap-south-1"
  profile  = "abhi"
}
resource "aws_vpc" "Main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "taskvpc"
  }
}
resource "aws_subnet" "main" {
  vpc_id     = "${aws_vpc.Main.id}"
  cidr_block = "10.0.0.0/24"
  availability_zone_id = "aps1-az1"
  tags = {
    Name = "tasksubnet1a"
  }
}
resource "aws_subnet" "Main" {
  vpc_id     = "${aws_vpc.Main.id}"
  cidr_block = "10.0.1.0/24"
  availability_zone_id = "aps1-az3"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "tasksubnet1b"
  }
}
resource "aws_internet_gateway" "taskgw" {
  vpc_id = "${aws_vpc.Main.id}"

  tags = {
    Name = "taskgw"
  }
}
resource "aws_route_table" "taskrouteig" {
  vpc_id = "${aws_vpc.Main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.taskgw.id}"
  }
 tags = {
    Name = "taskrouteig"
  }
}
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.Main.id
  route_table_id = aws_route_table.taskrouteig.id
}
resource "aws_security_group" "task_sec" {
  name        = "task_sec"
  description = "Allow SSH and HTTP"
  vpc_id      = "${aws_vpc.Main.id}"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
   ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "task_sec"
  }
}
resource "aws_security_group" "taskmysql_sec" {
  name        = "taskmysql_sec"
  description = "Allow MYSQL"
  vpc_id      = "${aws_vpc.Main.id}"
ingress {
    description = "TCP"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "taskmysql_sec"
  }
}

resource "aws_instance" "wpos" {
  ami           = "ami-96d6a0f9"
  instance_type = "t2.micro"
  key_name= "abhikey"
  vpc_security_group_ids= [aws_security_group.task_sec.id]
  subnet_id= "${aws_subnet.Main.id}"
  tags = {
    Name = "wpos"
  }
}
resource "aws_instance" "mysqlos" {
  ami           = "ami-08706cb5f68222d09"
  instance_type = "t2.micro"
  key_name= "abhikey"
  vpc_security_group_ids= [aws_security_group.taskmysql_sec.id]
  subnet_id= "${aws_subnet.main.id}"
  tags = {
    Name = "mysqlos1"
  }
}
