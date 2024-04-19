# Data source: Get latest AMI ID for Ubuntu 20.04 LTS
data "aws_ami" "ubuntu_20_04" {
  most_recent = true
  owners      = ["099720109477"]  # Canonical account ID for Ubuntu AMIs
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}
# Local variables
locals {
  user_data = <<-EOT
#!/bin/bash -xe
sudo apt-get update
sudo apt install openjdk-11-jre-headless -y
sudo apt-get install curl -y
echo "deb https://downloads.apache.org/cassandra/debian/dists/41x/main" | sudo tee -a /etc/apt/sources.list.d/cassandra.sources.list
curl https://downloads.apache.org/cassandra/KEYS | sudo apt-key add -
sudo apt-get update
sudo apt-get install cassandra -y
EOT
}

# Bastion server in public subnet 1
resource "aws_instance" "skyage-bastion-server" {
  ami                         = data.aws_ami.ubuntu_20_04.id
  instance_type               = "t2.micro"
  key_name                    = "demo"
  subnet_id                   = aws_subnet.public_subnet1.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.skyage-bastion-sg.id]
  tags = {
    "Name" = "bastion-server"
  }
}

# Three database servers in private subnets
resource "aws_instance" "skyage-database-server-1" {
  ami                         = data.aws_ami.ubuntu_20_04.id
  instance_type               = "t2.medium"
  key_name                    = "demo"
  subnet_id                   = aws_subnet.private_subnet1.id
  associate_public_ip_address = false
  vpc_security_group_ids      = [aws_security_group.skyage-db-SG.id]
  user_data                   = base64encode(local.user_data)
  tags = {
    "Name" = "database-server-1"
  }
}

resource "aws_instance" "skyage-database-server-2" {
  ami                         = data.aws_ami.ubuntu_20_04.id
  instance_type               = "t2.medium"
  key_name                    = "demo"
  subnet_id                   = aws_subnet.private_subnet2.id
  associate_public_ip_address = false
  vpc_security_group_ids      = [aws_security_group.skyage-db-SG.id]
  user_data                   = base64encode(local.user_data)
  tags = {
    "Name" = "database-server-2"
  }
}

resource "aws_instance" "skyage-database-server-3" {
  ami                         = data.aws_ami.ubuntu_20_04.id
  instance_type               = "t2.medium"
  key_name                    = "demo"
  subnet_id                   = aws_subnet.private_subnet2.id
  associate_public_ip_address = false
  vpc_security_group_ids      = [aws_security_group.skyage-db-SG.id]
  user_data                   = base64encode(local.user_data)
  tags = {
    "Name" = "database-server-3"
  }
}
