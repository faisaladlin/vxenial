#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

SET_LOCALE=en_US.UTF-8
SET_TIMEZONE=Asia/Kuala_Lumpur

SET_WWW_USER=ubuntu
SET_WWW_GROUP=ubuntu
SET_WWW_ROOT=/vagrant

SET_DB_NAME=vagrant
SET_DB_PASSWORD=vagrant
SET_DB_REMOTE_IP=192.168.33.1

SET_XDEBUG_REMOTE_IP=10.0.2.2
SET_XDEBUG_REMOTE_PORT=9000

SETUP_NODE8=0
SETUP_BUILD=0

SETUP_MYSQL=0
SETUP_MONGODB=0
SETUP_REDIS=0
SETUP_BEANSTALKD=0

SETUP_APACHE=0
SETUP_PHP7FPM=0
SETUP_COMPOSER=0
SETUP_XDEBUG=0

SETUP_LARAVEL=0

SETUP_BASH=1

echo $'\n------------------------------------------------------------------'
echo Validate setting dependencies \& apply adjustments

if [ ${SETUP_BUILD} = 1 ]; then

	if [ ${SETUP_NODE8} != 1 ]; then

		echo SETUP_BUILD Prerequisite \| SETUP_NODE8=1
		SETUP_NODE8=1
	fi	
fi

if [ ${SETUP_LARAVEL} = 1 ]; then

	if [ ${SETUP_COMPOSER} != 1 ]; then

		echo SETUP_LARAVEL Prerequisite \| SETUP_COMPOSER=1
		SETUP_COMPOSER=1
	fi

	if [ ${SET_WWW_ROOT} != '/vagrant/public' ]; then

		echo SETUP_LARAVEL Prerequisite \| SET_WWW_ROOT=/vagrant/public
		SET_WWW_ROOT=/vagrant/public
	fi	
fi

if [ ${SETUP_COMPOSER} = 1 ]; then

	if [ ${SETUP_PHP7FPM} != 1 ]; then

		echo SETUP_COMPOSER Prerequisite \| SETUP_PHP7FPM=1
		SETUP_PHP7FPM=1
	fi	
fi

if [ ${SETUP_XDEBUG} = 1 ]; then

	if [ ${SETUP_PHP7FPM} != 1 ]; then

		echo SETUP_XDEBUG Prerequisite \| SETUP_PHP7FPM=1
		SETUP_PHP7FPM=1
	fi	
fi

if [ ${SETUP_PHP7FPM} = 1 ]; then

	if [ ${SETUP_APACHE} != 1 ]; then

		echo SETUP_PHP7FPM Prerequisite \| SETUP_APACHE=1
		SETUP_APACHE=1
	fi	
fi

echo $'\n------------------------------------------------------------------'
echo Set default locales

echo $'LC_ALL='${SET_LOCALE}$'\nLANG='${SET_LOCALE}$'\nLANGUAGE='${SET_LOCALE}$'' | tee -a /etc/environment > /dev/null

echo $'\n------------------------------------------------------------------'
echo Set default timezone

timedatectl set-timezone ${SET_TIMEZONE}

if [ ${SETUP_MONGODB} = 1 ] || [ ${SETUP_REDIS} = 1 ] || [ ${SETUP_PHP7FPM} = 1 ] || [ ${SETUP_BEANSTALKD} = 1 ]; then

	echo $'\n------------------------------------------------------------------'
	echo Add external keys \& package archives

	if [ ${SETUP_MONGODB} = 1 ]; then

		apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2930ADAE8CAF5059EE73BB4B58712A2291FA4AD5
		echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.6 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-3.6.list
	fi

	if [ ${SETUP_REDIS} = 1 ] || [ ${SETUP_PHP7FPM} = 1 ] || [ ${SETUP_BEANSTALKD} = 1 ]; then

		add-apt-repository -y ppa:ondrej/php
	fi
	
	apt-get update -y
fi

echo $'\n------------------------------------------------------------------'
echo Setup common utilities \(curl, git, zip, software-properties-common\)

apt-get install -y curl git zip software-properties-common

if [ ${SETUP_NODE8} = 1 ]; then

	echo $'\n------------------------------------------------------------------'
	echo Setup Node 8, NPM \& Python 2.7 \(dependency\)

	curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
	apt-get install -y nodejs
fi

if [ ${SETUP_BUILD} = 1 ] && [ ${SETUP_NODE8} = 1 ]; then

	echo $'\n------------------------------------------------------------------'
	echo Setup build-essential packages

	apt-get install -y build-essential
fi

if [ ${SETUP_MYSQL} = 1 ]; then

	echo $'\n------------------------------------------------------------------'
	echo Setup MySQL \| Password: ${SET_DB_PASSWORD} \| Database: ${SET_DB_NAME} \| Allow Remote

	debconf-set-selections <<< "mysql-server mysql-server/root_password password $SET_DB_PASSWORD"
	debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $SET_DB_PASSWORD"

	apt-get install -y mysql-server

	mysql --defaults-extra-file=/etc/mysql/debian.cnf -Bse "CREATE USER 'root'@'$SET_DB_REMOTE_IP' IDENTIFIED BY '$SET_DB_PASSWORD';"
	mysql --defaults-extra-file=/etc/mysql/debian.cnf -Bse "GRANT ALL PRIVILEGES ON *.* TO 'root'@'$SET_DB_REMOTE_IP' WITH GRANT OPTION;"
	mysql --defaults-extra-file=/etc/mysql/debian.cnf -Bse "FLUSH PRIVILEGES;"
	mysql --defaults-extra-file=/etc/mysql/debian.cnf -Bse "CREATE DATABASE $SET_DB_NAME;"

	sed -i -e 's/bind-address/#bind-address/g' /etc/mysql/mysql.conf.d/mysqld.cnf
fi

if [ ${SETUP_MONGODB} = 1 ]; then

	echo $'\n------------------------------------------------------------------'
	echo Setup MongoDB \| Allow Remote

	apt-get install -y mongodb-org=3.6.0 mongodb-org-server=3.6.0 mongodb-org-shell=3.6.0 mongodb-org-mongos=3.6.0 mongodb-org-tools=3.6.0

	sed -i -e 's/bindIp: 127.0.0.1/bindIp: 0.0.0.0/g' /etc/mongod.conf
fi

if [ ${SETUP_REDIS} = 1 ]; then

	echo $'\n------------------------------------------------------------------'
	echo Setup Redis Server \| Allow Remote

	apt-get install -y redis-server

	sed -i -e 's/bind 127.0.0.1/#bind 127.0.0.1/g' /etc/redis/redis.conf
fi

if [ ${SETUP_BEANSTALKD} = 1 ]; then

	echo $'\n------------------------------------------------------------------'
	echo Setup Beanstalkd Server

	apt-get install -y beanstalkd
fi

if [ ${SETUP_APACHE} = 1 ]; then

	echo $'\n------------------------------------------------------------------'
	echo Setup Apache HTTPd \| As ${SET_WWW_USER}:${SET_WWW_GROUP}

	apt-get install -y apache2

	a2enmod rewrite

	sed -i -e 's/export APACHE_RUN_USER=www-data/export APACHE_RUN_USER='${SET_WWW_USER}'/g' /etc/apache2/envvars
	sed -i -e 's/export APACHE_RUN_GROUP=www-data/export APACHE_RUN_GROUP='${SET_WWW_GROUP}'/g' /etc/apache2/envvars

	sed -i -e 's@DocumentRoot /var/www/html@DocumentRoot '${SET_WWW_ROOT}'\n\n\t<Directory "'${SET_WWW_ROOT}'">\n\tAllowOverride All\n\tOptions +FollowSymLinks -Indexes\n\tRequire all granted\n\t</Directory>@g' /etc/apache2/sites-enabled/000-default.conf

	echo $'\n# Block access to dot-prefixed directories (i.e. .vagrant / .git)\n<DirectoryMatch ".*\/\..+">\nRequire all denied\n</DirectoryMatch>' | tee -a /etc/apache2/apache2.conf > /dev/null
	echo $'\n# Block access to dot-prefixed & vagrant configuration files\n<FilesMatch "(^\..+|Vagrantfile|Vagrantprovision\.sh)">\nRequire all denied\n</FilesMatch>\n' | tee -a /etc/apache2/apache2.conf > /dev/null

	if [ ${SETUP_PHP7FPM} = 1 ]; then

		echo $'\n------------------------------------------------------------------'
		echo Setup PHP CLI \& FastCGI Process Manager \| As ${SET_WWW_USER}:${SET_WWW_GROUP}

		if [ ${SETUP_MYSQL} = 1 ] && [ ${SETUP_REDIS} = 1 ]; then

			apt-get install -y php7.1 php7.1-fpm php7.1-cli php7.1-mbstring php7.1-xml php7.1-mysql php-redis

		elif [ ${SETUP_MYSQL} = 1 ]; then

			apt-get install -y php7.1 php7.1-fpm php7.1-cli php7.1-mbstring php7.1-xml php7.1-mysql

		elif [ ${SETUP_REDIS} = 1 ]; then

			apt-get install -y php7.1 php7.1-fpm php7.1-cli php7.1-mbstring php7.1-xml php-redis

		else

			apt-get install -y php7.1 php7.1-fpm php7.1-cli php7.1-mbstring php7.1-xml
		fi

		sed -i -e 's/user = www-data/user = '${SET_WWW_USER}'/g' /etc/php/7.1/fpm/pool.d/www.conf
		sed -i -e 's/group = www-data/group = '${SET_WWW_GROUP}'/g' /etc/php/7.1/fpm/pool.d/www.conf

		a2enmod proxy_fcgi setenvif
		a2enconf php7.1-fpm

		if [ ${SETUP_COMPOSER} = 1 ]; then

			echo $'\n------------------------------------------------------------------'
			echo Setup PHP Composer

			apt-get install -y composer
            composer config --global repo.packagist composer https://packagist.org
		fi

		if [ ${SETUP_XDEBUG} = 1 ]; then

			echo $'\n------------------------------------------------------------------'
			echo Setup PHP XDebug

			apt-get install -y php-xdebug

			grep -q -F 'xdebug.remote_enable' /etc/php/7.1/fpm/conf.d/20-xdebug.ini || echo $'xdebug.remote_enable=1' | tee -a /etc/php/7.1/fpm/conf.d/20-xdebug.ini > /dev/null
			grep -q -F 'xdebug.remote_host' /etc/php/7.1/fpm/conf.d/20-xdebug.ini || echo $'xdebug.remote_host='${SET_XDEBUG_REMOTE_IP}$'' | tee -a /etc/php/7.1/fpm/conf.d/20-xdebug.ini > /dev/null
			grep -q -F 'xdebug.remote_port' /etc/php/7.1/fpm/conf.d/20-xdebug.ini || echo $'xdebug.remote_port='${SET_XDEBUG_REMOTE_PORT}$'' | tee -a /etc/php/7.1/fpm/conf.d/20-xdebug.ini > /dev/null

			grep -q -F 'xdebug.remote_enable' /etc/php/7.1/cli/conf.d/20-xdebug.ini || echo $'xdebug.remote_enable=1' | tee -a /etc/php/7.1/cli/conf.d/20-xdebug.ini > /dev/null
			grep -q -F 'xdebug.remote_host' /etc/php/7.1/cli/conf.d/20-xdebug.ini || echo $'xdebug.remote_host='${SET_XDEBUG_REMOTE_IP}$'' | tee -a /etc/php/7.1/cli/conf.d/20-xdebug.ini > /dev/null
			grep -q -F 'xdebug.remote_port' /etc/php/7.1/cli/conf.d/20-xdebug.ini || echo $'xdebug.remote_port='${SET_XDEBUG_REMOTE_PORT}$'' | tee -a /etc/php/7.1/cli/conf.d/20-xdebug.ini > /dev/null
		fi

		if [ ${SETUP_LARAVEL} = 1 ]; then

			echo $'\n------------------------------------------------------------------'
			echo Setup Laravel project, dependencies \& configurations

			LARAVEL_INSTALLED=0

			# if laravel artisan exists
			if [ -f /vagrant/artisan ]; then

				LARAVEL_INSTALLED=1

				echo Laravel detected. Begin configuring...

			else

				echo Laravel not detected. Begin installing...

				VAGRANT_EMPTY=1 # vagrant folder considered empty by default

				for fileordirname in `ls -A /vagrant`; do
					if [ ${VAGRANT_EMPTY} = 1 ]; then
						if [ ${fileordirname} != ".DS_Store" ] && [ ${fileordirname} != "thumbs.db" ] && [ ${fileordirname} != "desktop.ini" ] && [ ${fileordirname} != ".git" ] && [ ${fileordirname} != ".gitignore" ] && [ ${fileordirname} != ".gitattributes" ] && [ ${fileordirname} != ".idea" ] && [ ${fileordirname} != ".vagrant" ] && [ ${fileordirname} != "Vagrantfile" ] && [ ${fileordirname} != "Vagrantprovision.sh" ] && [ ${fileordirname} != "README.md" ]; then
							# if file/directory other than .DS_Store, thumbs.db, desktop.ini,
							# .git, .gitignore, .gitattributes, .idea, .vagrant,
							# Vagrantfile or Vagrantprovision.sh is found,
							# /vagrant folder is NOT considered empty
							VAGRANT_EMPTY=0
						fi
					fi
				done

				if [ ${VAGRANT_EMPTY} = 0 ]; then

					echo Laravel installation ABORTED. /vagrant directory NOT EMPTY
					echo \* Should only contain Vagrantfile, Vagrantprovision.sh \& README.md

					SETUP_LARAVEL=0

				else

					composer create-project --prefer-dist laravel/laravel project

					rm project/readme.md
					
					mv -v project/* /vagrant
					mv -v project/.env.example /vagrant
					mv -v project/.gitattributes /vagrant
					mv -v project/.gitignore /vagrant

					rm -rf project

					LARAVEL_INSTALLED=1
				fi
			fi

			if [ ${LARAVEL_INSTALLED} = 1 ]; then

				# if composer.json file exists
				if [ -f /vagrant/composer.json ]; then

					# ... but vendor directory is missing
					if [ ! -d /vagrant/vendor ]; then

						# change current directory
						cd /vagrant

						# pull all dependencies
						composer install
					fi
				fi

				# if .env file is missing
				if [ ! -f /vagrant/.env ]; then

					# ... but .env.example file exists
					if [ -f /vagrant/.env.example ]; then

						# create new .env file from .env.example
						cp /vagrant/.env.example /vagrant/.env
					fi
				fi

				# if .env file exists
				if [ -f /vagrant/.env ]; then

					# update database name & password setting in .env
					sed -i -e 's/DB_DATABASE=homestead/DB_DATABASE='${SET_DB_NAME}'/g' /vagrant/.env
					sed -i -e 's/DB_USERNAME=homestead/DB_USERNAME=root/g' /vagrant/.env
					sed -i -e 's/DB_PASSWORD=secret/DB_PASSWORD='${SET_DB_PASSWORD}'/g' /vagrant/.env
				fi

				# if APP_KEY not set in .env file
				if ! grep -q 'APP_KEY=base64' /vagrant/.env; then

					# generate app key
					php /vagrant/artisan key:generate	
				fi
			fi

		fi
	fi
fi

if [ ${SETUP_BASH} = 1 ]; then

	echo $'\n------------------------------------------------------------------'
	echo Customize bash .profile script

	if [ ${SETUP_XDEBUG} = 1 ]; then

		echo Adds xdebug toggler \(xon / xoff\)

		echo $'\n# xdebug disabler command alias\nalias xoff="sudo sed -i -e \'s/^zend_extension=xdebug.so$/;zend_extension=xdebug.so/g\' /etc/php/7.1/fpm/conf.d/20-xdebug.ini; sudo sed -i -e \'s/^zend_extension=xdebug.so$/;zend_extension=xdebug.so/g\' /etc/php/7.1/cli/conf.d/20-xdebug.ini; sudo service php7.1-fpm restart; sudo service apache2 restart; echo \\"Xdebug DISABLED. Restarted PHP-FPM & Apache HTTPD\\""' | tee -a /home/ubuntu/.profile > /dev/null
		echo $'\n# xdebug enabler command alias\nalias xon="sudo sed -i -e \'s/^;zend_extension=xdebug.so$/zend_extension=xdebug.so/g\' /etc/php/7.1/fpm/conf.d/20-xdebug.ini; sudo sed -i -e \'s/^;zend_extension=xdebug.so$/zend_extension=xdebug.so/g\' /etc/php/7.1/cli/conf.d/20-xdebug.ini; sudo service php7.1-fpm restart; sudo service apache2 restart; echo \\"Xdebug ENABLED. Restarted PHP-FPM & Apache HTTPD\\""' | tee -a /home/ubuntu/.profile > /dev/null
	fi

	if [ ${SETUP_COMPOSER} = 1 ]; then

		echo Adds composer alias
		echo $'\n# composer as sudo composer\nalias composer="sudo composer"' | tee -a /home/ubuntu/.profile > /dev/null	
	fi

	if [ ${SETUP_LARAVEL} = 1 ]; then

		echo Adds artisan alias
		echo $'\n# laravel artisan command alias\nalias artisan="sudo php artisan"' | tee -a /home/ubuntu/.profile > /dev/null
	fi

	echo Change into /vagrant directory upon login
	echo $'\n# change into /vagrant directory upon login\ncd /vagrant' | tee -a /home/ubuntu/.profile > /dev/null
fi

echo $'\n------------------------------------------------------------------'
echo Restarting Servers

[[ ${SETUP_MYSQL} = 1 ]] && service mysql restart
[[ ${SETUP_MONGODB} = 1 ]] && service mongod restart
[[ ${SETUP_REDIS} = 1 ]] && service redis-server restart
[[ ${SETUP_BEANSTALKD} = 1 ]] && service beanstalkd restart

[[ ${SETUP_APACHE} = 1 ]] && service apache2 restart
[[ ${SETUP_PHP7FPM} = 1 ]] && service php7.1-fpm restart

echo $'\n------------------------------------------------------------------'
echo PROVISIONING DONE
