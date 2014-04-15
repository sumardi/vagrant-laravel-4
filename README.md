# Laravel 4 with Vagrant
Easy development environment for Laravel 4 with Vagrant. `Shell` is used for provisioning. Maintained by [Sumardi Shukor](https://about.me/sumardi).

## Requirements
* [Virtualbox 4.3.x](https://www.virtualbox.org/wiki/Downloads)
* [Vagrant 1.5.x](https://www.vagrantup.com/downloads.html)

## Setup

First, clone this repository.
```
git clone https://github.com/sumardi/vagrant-laravel-4.git
```
Then, fire up Vagrant.
```
vagrant up
```

The first time you run vagrant it will need to fetch the virtual box image which is ~300mb so depending on your download speed this could take some time. Grab a cup of `0xC00FEE`!

After the provisioning has completed, you can access your project at http://192.168.13.37 in a browser.

> Note: You may have to change permissions on the public/laravel/app/storage folder to writeable under the host OS.

> For example: `chmod -R 777 public/laravel/app/storage`

## Installed Software

* Centos 6.5 (32bit)
* Apache 2
* MySQL 5
* PHP 5.4 (with mbstring, mysql, curl, gd, dom, mcrypt, imap, xdebug, pdo, pear)
* Composer
* PHPUnit
* phpMyAdmin
* Beanstalkd (with Beanstalk Console)
* Supervisord
* NodeJS (with Grunt, Gulp)

## Default Credentials
### MySQL
* User: root
* Password: (blank)
* Port Forwarded : `3306` => `1337`

### Apache
* ServerName : localhost.localdomain
* Port Forwarded : `80` => `8080`

### Beanstalkd
* Port : `11300`

### Beanstalk Console

* http://192.168.13.37/beanstalk_console

## Resources

### Vagrant

Vagrant is very [well documented](http://docs.vagrantup.com/v2/) but here are a few common commands:

* `vagrant up` starts and provisions the vagrant environment
* `vagrant suspend` suspends the machine
* `vagrant resume` resume a suspended vagrant machine
* `vagrant halt` stops the vagrant machine
* `vagrant ssh` connects to machine via SSH
* `vagrant destroy` stops and deletes all traces of the vagrant machine
* `vagrant reload` restarts vagrant machine, loads new Vagrantfile configuration
