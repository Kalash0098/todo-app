#key pair
resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCsEe4aPMm2rdy5cMXnfdFu/Lty9N6iNbhuWKGymhvxLEP1feuGxXqRd0O2ke2p0tH39UqmpZhfqZLj+gEcPywqd2BzXpTRDx91OxihFkHvAHMtzR8YqesNtAFq8g3zpLgeMoXVEmxHRHY0LheFnf2YQdvYKADvSDPyiQKTq0jmjg3ACSNy5K0Q6CwuLt/4eUgrRYJr7u9evfWVGhZwOBm2YgqvHNt3EfglQkdRFFBwVpsEGE0Hv8odkd03vRuU6Fx+/FYibl1H5Ba1LoU04EehcUTe6bp2e1Ho15h3f36HVwBJMKTD1xn/AdaY4mqlvpuZjvn3O4PZGr60UTMYZQTvMGhJZI3DzQ4KSl2qIVcd7as1mqIK60fw3mMW7RJiiwo3CHe9FNtG2IgV5uDjgoToVKGOkK6ZPjpgg1UFZnrxGh9PDug+Kqceo+iPGyyATg0Opa1AjttlKZMcqApWca8KnYz41qxX4Z9+HjXAs7JORo/tkd3TkUt7n6omCt3G71XSGAMDwEoIjAW7QFJT7IdeS3KQDIYp6gb1J5pkR5BIA581uNFzrg9gtzY7cBww+/4SLJNRC3qU7pzs/VKQ+CDU0yiKzGh7BqpOmSugLyhnHT01e9AzUkvUP4WcLsVBGAEnLbAijJ2vbNQXVBM049beApO6JLCpcCTIOA8TranDUQ== ubuntu@ip-172-31-91-17"
}

#VPC & Security Group
resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

resource "aws_security_group" "my_security_group" {
  name= "my-security-group"
  description = "this terra form security group"
  vpc_id = aws_default_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
 ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#ec2 instance
resource "aws_instance" "todo-app"{
    key_name=aws_key_pair.deployer.key_name
    ami = "ami-0d001f8052688dc45"
    instance_type = "t3.large"
    security_groups = [aws_security_group.my_security_group.name]

    root_block_device {
        volume_size = 15
        volume_type = "gp3"
    }
    tags = {
        Name = "todo-app"
    }
}  
