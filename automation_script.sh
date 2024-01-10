sudo dnf module reset php
sudo dnf module enable php:7.4
sudo dnf install httpd php php-mysqlnd php-gd php-xml mariadb-server mariadb php-mbstring php-json mod_ssl php-intl php-apcu -y
sudo systemctl start mariadb
sudo mysql_secure_installation <<EOF

y
secret
secret
y
y
y
y
EOF
sudo mysql -u root --password=secret -e "CREATE USER 'wiki'@'localhost' IDENTIFIED BY 'Testing12345';"
sudo mysql -u root --password=secret -e "CREATE DATABASE wikidatabase;"
sudo mysql -u root --password=secret -e "GRANT ALL PRIVILEGES ON wikidatabase.*TO 'wiki'@'localhost';"
sudo mysql -u root --password=secret -e "FLUSH PRIVILEGES;"
sudo systemctl enable mariadb
sudo systemctl enable httpd
# sudo sed -i 's/^\(DocumentIndex\s\+\)/\1index.php /' /etc/httpd/conf/httpd.conf
sudo sed -i 's/^\(DirectoryIndex\s\+\)index.html/\1index.html index.php/' /etc/httpd/conf/httpd.conf
sudo sed -i 's|^DocumentRoot "/var/www/html"|DocumentRoot "/var/www"|' /etc/httpd/conf/httpd.conf
cd /home
sudo wget https://releases.wikimedia.org/mediawiki/1.41/mediawiki-1.41.0.tar.gz
cd /var/www/
sudo tar -zxf /home/mediawiki-1.41.0.tar.gz
sudo ln -s mediawiki-1.41.0/ mediawiki
sudo systemctl restart httpd
sudo firewall-cmd --permanent --zone=public --add-service=http
sudo firewall-cmd --permanent --zone=public --add-service=https
sudo systemctl restart firewalld
sudo restorecon -FR /var/www/mediawiki-1.41.0/
sudo restorecon -FR /var/www/mediawiki
# restorecon -FR /var/www/mediawiki