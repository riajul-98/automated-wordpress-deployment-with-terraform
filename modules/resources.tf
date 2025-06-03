# Creating Security Group which allows HTTP and SSH access
resource "aws_security_group" "wordpress_SG" {
    description = "HTTP and SSH access"
    tags = {
      Name = "Wordpress_SG"
    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }
}

# Creating EC2 instance with wordpress set up in user data
resource "aws_instance" "Wordpress_server" {
    ami = local.ami
    instance_type = var.instance_type
    vpc_security_group_ids = [aws_security_group.wordpress_SG.id]
    user_data = <<-EOF
    #!/bin/bash
    apt update -y
    apt install apache2 php php-mysql libapache2-mod-php mysql-server unzip wget -y

    systemctl enable apache2
    systemctl start apache2
    systemctl enable mysql
    systemctl start mysql

    mysql -e "CREATE DATABASE wordpress DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
    mysql -e "CREATE USER 'wordpressuser'@'localhost' IDENTIFIED BY '${var.db_password}';"
    mysql -e "GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpressuser'@'localhost';"
    mysql -e "FLUSH PRIVILEGES;"

    cd /tmp
    wget https://wordpress.org/latest.zip
    unzip latest.zip
    cp -r wordpress/* /var/www/html/
    chown -R www-data:www-data /var/www/html/
    chmod -R 755 /var/www/html/
    rm /var/www/html/index.html

    cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
    sed -i "s/database_name_here/wordpress/" /var/www/html/wp-config.php
    sed -i "s/username_here/wordpressuser/" /var/www/html/wp-config.php
    sed -i "s/password_here/${var.db_password}/" /var/www/html/wp-config.php
    systemctl restart apache2
  EOF
    key_name = "test"
    tags = {
      Name = "Wordpress Server"
    }
}

# Configuring cloudflare DNS records
resource "cloudflare_dns_record" "wordpress_record" {
    zone_id = local.zone_id
    name = "tm"
    type = "A"
    content = aws_instance.Wordpress_server.public_ip
    depends_on = [aws_instance.Wordpress_server]
    ttl = 3600
}