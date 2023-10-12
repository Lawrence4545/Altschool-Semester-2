#!/usr/bin/env bash

# Use single quotes instead of double quotes to make it work with special-character passwords
PASSWORD='root'
PROJECTFOLDER='Project'

# create project folder
sudo mkdir "/var/www/html/${PROJECTFOLDER}"

# update / upgrade
sudo apt-get update
sudo apt-get -y upgrade

# install apache
sudo apt-get install -y apache2

# install php7.4
sudo apt-get install software-properties-common
sudo LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php
sudo apt-get update
sudo apt-get install -y php7.4 php7.4-bcmath php7.4-bz2 php7.4-cli php7.4-curl php7.4-intl php7.4-json php7.4-mbstring php7.4-opcache php7.4-soap php7.4-xml php7.4-xsl php7.4-zip libapache2-mod-php7.4 php7.4-mysql

sed -i 's/max_execution_time = .*/max_execution_time = 60/' /etc/php/7.4/apache2/php.ini
sed -i 's/post_max_size = .*/post_max_size = 64M/' /etc/php/7.4/apache2/php.ini
sed -i 's/upload_max_filesize = .*/upload_max_filesize = 1G/' /etc/php/7.4/apache2/php.ini
sed -i 's/memory_limit = .*/memory_limit = 512M/' /etc/php/7.4/apache2/php.ini

sudo service apache2 restart

# install mysql and give password to installer
DBHOST=localhost
DBNAME=mydb
DBUSER=myuser
DBPASSWD=password

# Install MySQL
apt-get update

debconf-set-selections <<< "mysql-server mysql-server/root_password password $DBPASSWD"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $DBPASSWD"

apt-get -y install mysql-server-5.7

# Create the database and grant privileges
CMD="mysql -uroot -p$DBPASSWD -e"

$CMD "CREATE DATABASE IF NOT EXISTS $DBNAME"
$CMD "GRANT ALL PRIVILEGES ON $DBNAME.* TO '$DBUSER'@'%' IDENTIFIED BY '$DBPASSWD';"
$CMD "FLUSH PRIVILEGES;"

# Allow remote access to the database
sudo sed -i "s/.*bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf

sudo service mysql restart

# setup hosts file
VHOST=$(cat <<EOF
<VirtualHost *:80>
    DocumentRoot "/var/www/html/${PROJECTFOLDER}"
    <Directory "/var/www/html/${PROJECTFOLDER}">
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF
)
echo "${VHOST}" > /etc/apache2/sites-available/000-default.conf

# enable mod_rewrite
sudo a2enmod rewrite

# restart apache
service apache2 restart
