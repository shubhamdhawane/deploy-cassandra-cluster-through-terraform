# Data source:  Get latest AMI ID for Amazon Linux2 OS
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-*-gp2"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
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

# System Updates
sudo yum -y update

# STEP 1 - Install cassandraDB


EOT
}



# bastion-server in public-subnet-1
resource "aws_instance" "skyage-bastion-server" {
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = "t2.micro"
  key_name                    = "demo"
  subnet_id                   = aws_subnet.public_subnet1.id
  associate_public_ip_address = "true"
  vpc_security_group_ids      = [aws_security_group.skyage-bastion-sg.id]
  tags = {
    "Name" = "bastion-server"
  }
}


# three database-servers in private-subnets
resource "aws_instance" "skyage-database-server-1" {
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = "t2.medium"
  key_name                    = "demo"
  subnet_id                   = aws_subnet.private_subnet1.id
  associate_public_ip_address = "false"
  vpc_security_group_ids      = [aws_security_group.skyage-App-SG.id]
  user_data                   = base64encode(local.user_data)
  #user_data = file("deploy-app.sh")
  tags = {
    "Name" = "database-server-1"
  }
  depends_on = [
    aws_db_instance.db_instance
  ]
}


resource "aws_instance" "skyage-database-server-2" {
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = "t2.medium"
  key_name                    = "demo"
  subnet_id                   = aws_subnet.private_subnet2.id
  associate_public_ip_address = "false"
  vpc_security_group_ids      = [aws_security_group.skyage-App-SG.id]
  user_data                   = base64encode(local.user_data)
  #user_data = file("deploy-app.sh")
  tags = {
    "Name" = "database-server-2"
  }
  depends_on = [
    aws_db_instance.db_instance
  ]
}

resource "aws_instance" "skyage-database-server-3" {
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = "t2.medium"
  key_name                    = "demo"
  subnet_id                   = aws_subnet.private_subnet2.id
  associate_public_ip_address = "false"
  vpc_security_group_ids      = [aws_security_group.skyage-App-SG.id]
  user_data                   = base64encode(local.user_data)
  #user_data = file("deploy-app.sh")
  tags = {
    "Name" = "database-server-3"
  }
  depends_on = [
    aws_db_instance.db_instance
  ]
}
