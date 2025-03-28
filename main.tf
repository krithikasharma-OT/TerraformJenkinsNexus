data "aws_eks_cluster" "my_cluster" {
    name = "my-eks-cluster"
}

data "aws_vpc" "eks_vpc" {
  id = data.aws_eks_cluster.my_cluster.vpc_config[0].vpc_id
}


data "aws_subnets" "public_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.eks_vpc.id]
  }

  filter {
    name   = "tag:Name"
    values = ["*Public*"]
  }
}

data "aws_subnets" "private_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.eks_vpc.id]
  }

  filter {
    name   = "tag:Name"
    values = ["*Private*"]
  }
}

output "public_subnet_ids" {
  value = data.aws_subnets.public_subnets.ids
}

output "private_subnet_ids" {
  value = data.aws_subnets.private_subnets.ids
}


resource "aws_instance" "jenkins" {
  ami           = var.jenkins_ami_id
  instance_type = var.jenkins_instance_type
  subnet_id     = data.aws_subnets.public_subnets.ids[0]
  key_name      = var.jenkins_key_name
  security_groups = [aws_security_group.jenkins_sg.id]
  
  root_block_device {
    volume_size = var.jenkins_disk_space   
    volume_type = "gp3"
  }

  tags = {
    Name = "Jenkins-Server"
  }

  user_data = file("./jenkinsTrivySetup.sh")
}

resource "aws_security_group" "jenkins_sg" {
  name_prefix = "jenkins-sg"
  description = "Security group for Jenkins server"
  vpc_id      = data.aws_vpc.eks_vpc.id  

  # Allow inbound traffic on Jenkins port (8080)
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
  }

  # Allow inbound SSH (port 22)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
  }

  # Allow ICMP (ping)
  ingress {
    from_port   = -1  
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Jenkins-SG"
  }
}

resource "aws_instance" "SonarNexusServer_instance" {
  ami           = var.SonarNexusServer_instance_ami_id
  instance_type = var.SonarNexusServer_instance_type
  subnet_id     = data.aws_subnets.public_subnets.ids[1]
  key_name      = var.SonarNexusServer_instance_key_name
  security_groups = [aws_security_group.SonarNexusServer_sg.id]
  
  root_block_device {
    volume_size = var.SonarNexusServer_disk_space
    volume_type = "gp3"
  }

  tags = {
    Name = "SonarNexus-Server"
  }

  user_data = file("./sonarNexusSetup.sh")
}

resource "aws_security_group" "SonarNexusServer_sg" {
  name_prefix = "sonar-nexus-sg"
  description = "Security group for Sonar Nexus server"
  vpc_id      = data.aws_vpc.eks_vpc.id  

  ingress {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
  }

  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
  }

  ingress {
    from_port   = -1  
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Jenkins-SG"
  }
}

resource "aws_instance" "MongoDbServer_instance" {
  ami           = var.MongoDbServer_instance_ami_id
  instance_type = var.MongoDbServer_instance_type
  subnet_id     = data.aws_subnets.private_subnets.ids[0]
  key_name      = var.MongoDbServer_instance_key_name
  security_groups = [aws_security_group.MongoDbServer_sg.id]
  
  root_block_device {
    volume_size = var.MongoDbServer_disk_space
    volume_type = "gp3"
  }

  tags = {
    Name = "MongoDb-Server"
  }

  user_data = file("./MongoDbSetup.sh")
}

resource "aws_security_group" "MongoDbServer_sg" {
  name_prefix = "MongoDb-sg"
  description = "Security group for MongoDb server"
  vpc_id      = data.aws_vpc.eks_vpc.id  

  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
  }

  # Allow ICMP (ping)
  ingress {
    from_port   = -1  
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "MongoDb-SG"
  }
}
