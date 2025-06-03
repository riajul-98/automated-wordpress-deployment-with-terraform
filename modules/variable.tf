variable "instance_type" {
    type = string
    default = "t2.micro"
}

locals {
  ami = "ami-0a94c8e4ca2674d5a"
  zone_id = "2786dd2a42636b5abe9e3293e30f4442"
}

output "wordpress_ip" {
    description = "Public IP for wordpress instance"
    value = aws_instance.Wordpress_server.id
}

variable "db_password" {
  type        = string
  description = "Password for the WordPress database user"
  sensitive   = true
}
