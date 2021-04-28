## Creating VPC 

resource "aws_vpc" "vpc_backbase" {
  cidr_block = "172.16.0.0/16"
}

### Creating subnet

resource "aws_subnet" "my_subnet" {
  vpc_id            = aws_vpc.vpc_backbase.id
  cidr_block        = "172.16.10.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "tf-backbase"
  }
}

### Creating Network Interface

resource "aws_network_interface" "backbase_interface" {
  subnet_id   = aws_subnet.my_subnet.id
  private_ips = ["172.16.10.100"]

  tags = {
    Name = "primary_network_interface"
  }
}

### Creating Internet Gateway

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc_backbase.id

  tags = {
    Name = "main"
  }
}

### Creating routing table and association

resource "aws_route_table" "route-table-test-env" {
  vpc_id = aws_vpc.vpc_backbase.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

}
resource "aws_route_table_association" "subnet-association" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.route-table-test-env.id
}


### Creating Security Groups 

resource "aws_key_pair" "centos" {
  key_name   = "centos"
  public_key = file("id_rsa.pub")
}

resource "aws_security_group" "centos" {
  name        = "centos-security-group"
  description = "Allow HTTP, HTTPS and SSH traffic"
  vpc_id      = aws_vpc.vpc_backbase.id

  ingress {
    description = "SSH"
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

  tags = {
    Name = "terraform"
  }
}

##Creating Instance 

data "aws_ami" "centos" {
  owners      = ["679593333241"]
  most_recent = true

  filter {
    name   = "name"
    values = ["CentOS Linux 7 x86_64 HVM EBS *"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}


resource "aws_instance" "centos" {
  key_name      = aws_key_pair.centos.key_name
  ami           = data.aws_ami.centos.id
  instance_type = "t2.micro"

  tags = {
    Name = "centos"
  }

  vpc_security_group_ids = [
    "${aws_security_group.centos.id}"
  ]

  subnet_id = aws_subnet.my_subnet.id

  connection {
    type        = "ssh"
    user        = "centos"
    private_key = file("id_rsa")
    host        = self.public_ip
  }

  ebs_block_device {
    device_name = "/dev/sda1"
    volume_type = "gp2"
    volume_size = 30
  }
}

## Assigning public IP

resource "aws_eip" "centos" {
  vpc      = true
  instance = aws_instance.centos.id
}
