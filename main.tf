#first define your provider, search and download the source code for your preferred provider online. this defines the provider you want to use

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.48.0" #version is optional, u can remove this line
    }
  }
}

provider "aws" {
  region = "us-east-1"
  # Configuration options
}

resource "aws_instance" "terra-inst1" {
  ami           = "ami-0574da719dca65348" #goto to d ec2 console, deploy inst search for d ami u want e.g 'ubuntu' and copy
  instance_type = "t2.micro"
  security_groups = [ aws_security_group.instance.name ]
  user_data = <<-EOF
              #!/bin/bash
              echo "<h1>HELLO world from my first instance</h1>" > index.html
              python3 -m http.server 8080 &
              EOF

  tags = {
    Name = "first-inst-with-tf1"
  }
}

resource "aws_instance" "terra-inst2" {
  ami           = "ami-0574da719dca65348"
  instance_type = "t2.micro"
  security_groups = [ aws_security_group.instance.name ]
  user_data = <<-EOF
              #!/bin/bash
              echo "<h1>HELLO world from instance 2</h1>" > index.html
              python3 -m http.server 8080 &
              EOF

  tags = { #tag is optional
    Name = "first-inst-with-tf2"
  }
}

data "aws_vpc" "default_vpc" {      # data block references an existing resource on aws
  default = true
}

data "aws_subnet_ids" "default_subnet" {
  vpc_id = data.aws_vpc.default_vpc.id
}

resource "aws_security_group" "instance" {
  name = "instance-security-group"
}

resource "aws_security_group_rule" "allow_http_inbound" {
  type = "ingress"
  security_group_id = aws_security_group.instance.id

  from_port = 8080
  to_port = 8080
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

# setup load balancer listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.load_balancer.arn

  port = 80
  protocol = "HTTP"

  # By default, return a simple 404 page
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code = 404
    }
  }
  
}

# setup target group for the load balancer
resource "aws_lb_target_group" "intances" {
  name = "example-target-group"
  port = 8080
  protocol = "HTTP"
  vpc_id = data.aws_vpc.default_vpc.id

  health_check {
    path = "/"
    protocol = "HTTP"
    matcher = "200"
    interval = 15
    timeout = 3
    healthy_threshold = 2
    unhealthy_threshold = 2
  }
  
}

resource "aws_lb_target_group_attachment" "instance_1" {
  target_group_arn = aws_lb_target_group.intances.arn
  target_id = aws_instance.terra-inst1.id
  port = 8080
  
}

resource "aws_lb_target_group_attachment" "instance_2" {
  target_group_arn = aws_lb_target_group.intances.arn
  target_id = aws_instance.terra-inst2.id
  port = 8080
  
}

resource "aws_lb_listener_rule" "instances" {
  listener_arn = aws_lb_listener.http.arn
  priority = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }
  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.intances.arn
  }
  
}

resource "aws_security_group" "alb" {
  name = "alb-security-group"
  
}

resource "aws_security_group_rule" "allow_alb_http_inbound" {
  type = "ingress"
  security_group_id = aws_security_group.alb.id

  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}
resource "aws_security_group_rule" "allow_alb_all_outbound" {
  type = "egress"
  security_group_id = aws_security_group.alb.id

  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_lb" "load_balancer" {
  name = "web-app-alb"
  load_balancer_type = "application"
  subnets = data.aws_subnet_ids.default_subnet.ids
  security_groups = [aws_security_group.alb.id]
  
}

resource "aws_route53_zone" "primary" {
  name = "tokkapart.com"
  
}

resource "aws_route53_record" "root" {
  zone_id = aws_route53_zone.primary.zone_id
  name = "tokkapart.com"
  type = "A"

  alias {
    name = aws_lb.load_balancer.dns_name
    zone_id = aws_lb.load_balancer.zone_id
    evaluate_target_health = true
  }
}

resource "aws_db_instance" "db_instance" {
  allocated_storage = 20
  storage_type = "standard"
  engine = "postgres"
  engine_version = "12.5"
  instance_class = "db.t2.micro"
  db_name = "mydb"              #these hard-coded db credentials will be handled the proper way, when we advance to variables
  username = "mydb"             # for now hard-code all.
  password = "mydb"
  skip_final_snapshot = true

}