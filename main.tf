terraform {
  backend "remote" {
    hostname     = "aedifexhack.jfrog.io"
    organization = "aedifex_test"
    workspaces {
      prefix = "my-prefix-"
    }
  }
}

terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region  = "us-east-2"
#  profile = "aedifex_admin"
}

resource "aws_security_group" "allow_web" {
  name        = "allow_web_ssh"
  description = "Allow web inbound traffic and ssh"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
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
    Name = "allow_web_ssh"
  }
}

resource "aws_instance" "web" {
  ami             = "ami-0fb653ca2d3203ac1"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.allow_web.name]
  key_name        = "JFrog"

  user_data = <<-EOF
                #!/bin/bash
                # Install Docker
                sudo apt-get update
                sudo apt-get install -y \
                    apt-transport-https \
                    ca-certificates \
                    curl \
                    software-properties-common
                curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
                sudo add-apt-repository \
                    "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
                sudo apt-get update
                sudo apt-get install -y docker-ce docker-ce-cli containerd.io
                sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common unzip
                
                # Install AWS CLI v2
                sudo curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
                sudo unzip awscliv2.zip
                sudo ./aws/install
                
                # Setup AWS CLI credentials
                sudo mkdir -p /root/.aws
                sudo tee /root/.aws/credentials > /dev/null <<EOL
                [default]
                aws_access_key_id = ${var.aws_access_key}
                aws_secret_access_key = ${var.aws_secret_key}
                EOL
                
                # Authenticate Docker to Amazon ECR
                aws ecr get-login-password --region us-east-2 | sudo docker login --username AWS --password-stdin 824987503353.dkr.ecr.us-east-2.amazonaws.com
                
                # Pull the Docker image from ECR
                sudo docker pull 824987503353.dkr.ecr.us-east-2.amazonaws.com/jfrog:tag
                
                # Optionally run the Docker container
                sudo docker run -d -p 8080:80 824987503353.dkr.ecr.us-east-2.amazonaws.com/jfrog:tag >> /var/log/docker_run.log 2>&1
                EOF

  tags = {
    Name = "DockerNginxInstance"
  }
}

output "instance_public_ip" {
  value = aws_instance.web.public_ip
}

output "instance_security_group_id" {
  value = aws_security_group.allow_web.id
}
