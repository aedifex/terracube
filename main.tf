provider "aws" {
  region = "us-west-1"
  # Uncomment if you store your aws credentials file unconventionally.
  # shared_credentials_file = "~/.aws/credentials"
  # profile = var.aws_instance_profile
}

terraform {
  backend "s3" {
    bucket = "terracube"
    key    = "terraform.tfstate"
    region = "us-west-1"
  }
}

resource "aws_security_group" "instance" {
  name = "terracube-example"
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "example" {
  ami                    = "ami-059b818564104e5c6"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.instance.id]
  user_data              = <<-EOF
              #!/bin/bash
              echo "<h1>Hello from CircleCI!</h1>" > index.html
              nohup busybox httpd -f -p 8080 &
              EOF
  tags = {
    Name = "terraform-example"
  }
}

output "instance_ips" {
  value = ["${aws_instance.example.*.public_ip}"]
}