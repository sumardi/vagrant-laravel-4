#!/usr/bin/env bash

echo ">>> Starting Install Script"

# Update
sudo yum -y --verbose update
sudo rpm -Uvh http://mirror.webtatic.com/yum/el6/latest.rpm
sudo rpm -Uvh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm

echo ">>> Installing Base"

# http://bixly.com/blog/supervisord-or-how-i-learned-to-stop-worrying-and-um-use-supervisord/
sudo groupadd supervisor
sudo usermod -a -G supervisor vagrant

# Install base items
# sudo yum install -y --verbose vim curl wget build-essential python-software-properties python-setuptools libaio gcc gcc-c++ make automake autoconf

# python stuffs
# sudo yum install -y --verbose zlib-devel bzip2-devel openssl-devel ncurses-devel
# echo ">>> Installing Ruby Items ... tools etc ..."

# Ruby has many useful tools
# sudo yum -y install ruby rubygems  curl-devel openssl-devel zlib-devel httpd-devel apr-devel apr-util-devel sqlite-devel
# sudo yum -y install ruby-rdoc ruby-devel
# sudo gem update --system

# Update Again
# sudo yum -y --verbose update

echo ">>> Installing Apache, PHP 5.4 & MySQL ..."

# Install all the other full stuff for web we need
sudo yum install -y --verbose git-core php54w php54w-cli php54w-common httpd php54w-curl php54w-mbstring php54w-mysql php54w-gd php54w-dom php54w-mcrypt php54w-imap php54w-xdebug php54w-pdo php54w-pear
sudo yum install -y --verbose mysql mysql-server
sudo yum install -y --verbose phpmyadmin
sudo chmod -R 755 /var/lib/mysql/
sudo service mysqld restart
sudo cp -f /vagrant/conf/httpd/phpMyAdmin.conf /etc/httpd/conf.d/phpMyAdmin.conf
sudo cp -f /vagrant/conf/phpMyAdmin/config.inc.php /etc/phpMyAdmin/config.inc.php

# make sure mysqld restarts with the server
sudo chkconfig --add mysqld
sudo chkconfig --level 345 mysqld on

# Install PHPUnit
command -v phpunit >/dev/null 2>&1 || {
    sudo pear upgrade-all
    sudo pear channel-discover pear.phpunit.de
    sudo pear install phpunit/PHPUnit
}

# PHP Config
sudo sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php.ini
sudo sed -i "s/display_errors = .*/display_errors = On/" /etc/php.ini
sudo sed -i "s/#ServerName www.example.com:80/ServerName localhost.localdomain/" /etc/httpd/conf/httpd.conf

echo ">>> Configured web services ... restarting httpd"
sudo service httpd restart

# make sure httpd restarts with the server
sudo chkconfig --add httpd
sudo chkconfig --level 345 httpd on

# Beanstalkd
command -v beanstalkd >/dev/null 2>&1 || {
    echo ">>> Installing beanstalkd "
    sudo yum install -y --verbose beanstalkd
    sudo service beanstalkd start

    # make sure beanstalkd restarts with the server
    sudo chkconfig --add beanstalkd
    sudo chkconfig --level 345 beanstalkd on
}

# Composer
command -v /usr/local/bin/composer >/dev/null 2>&1 || {
    echo ">>> Installing Composer"
    curl -sS https://getcomposer.org/installer | php
    sudo mv composer.phar /usr/local/bin/composer
}

if [ ! -d "/var/www/laravel" ]; then
    echo ">>> Installing Laravel"
    cd /var/www
    /usr/local/bin/composer create-project laravel/laravel --prefer-dist
    sudo chmod --recursive a+rw /var/www/laravel/app/storage
    sudo cp /vagrant/conf/httpd/laravel.conf /etc/httpd/conf.d/laravel.conf
else
    echo ">>> Updating Laravel"
    cd /var/www/laravel
    /usr/local/bin/composer update
fi

echo ">>> Configured web services ... restarting httpd"
sudo service httpd restart

# command -v supervisord >/dev/null 2>&1 || {
    echo ">>> Installing supervisor"

    sudo yum install -y --verbose python-pip.noarch
    sudo pip install supervisor
    sudo mkdir /etc/supervisor.d/
    sudo touch /etc/supervisor.d/laravel-listener.conf
    sudo touch /etc/supervisord.conf
    sudo cp /vagrant/conf/supervisord/supervisord.conf /etc/supervisord.conf
    sudo cp /vagrant/conf/supervisord/laravel-listener.conf /etc/supervisor.d/laravel-listener.conf

    # make sure supervisord restarts with the server
    sudo cp -r /vagrant/conf/init.d/supervisord /etc/init.d/supervisord
    sudo chmod a+x /etc/init.d/supervisord
    sudo chkconfig --add supervisord
    sudo chkconfig --level 345 supervisord on
# }

sudo unlink /tmp/supervisor.sock
sudo supervisord -c /etc/supervisord.conf
sudo supervisorctl reload

command -v npm >/dev/null 2>&1 || {
  echo ">>> Installing NodeJS & NPM"

  sudo yum install -y --verbose nodejs npm

  npm install -g grunt-cli
  npm install -g gulp
}

echo ">>> Done!"
