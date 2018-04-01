# Vagrant Xenial Canvas #

A configurable vagrant provisioning script for the stock ubuntu/xenial64 Vagrant box

### How it differs from the stock ubuntu/xenial64 script ###

* Runs Vagrantprovision.sh during provision
* Disables: vagrant box update checking
* Disables: writing vagrant console.log
* Sync Folder: . -> /vagrant (vagrant:vagrant user:group)
* Memory Allocation: 3GB (composer & npm tends to fail with less)
* SSH into /vagrant folder by default (instead of ~)

### Vagrantprovision.sh options ###

Feel free to customize Vagrantprovision.sh for your project.  
Available configurations (provisioning variables):

**SET_LOCALE**=en_US.UTF-8  
**SET_TIMEZONE**=Asia/Kuala_Lumpur  
**SET_HOST_NAME**=ubuntu-xenial  
**SET_HOST_FQDN**=ubuntu-xenial.vagrant.host

**SET_WWW_USER**=vagrant  
**SET_WWW_GROUP**=vagrant  
**SET_WWW_ROOT**=/vagrant/public

**SET_DB_HOST**=127.0.0.1  
**SET_DB_NAME**=vagrant  
**SET_DB_PASSWORD**=vagrant  
**SET_DB_REMOTE_IP**=192.168.33.1

**SET_REDIS_HOST**=127.0.0.1

**SET_PHP_DISPLAY_ERRORS**=On  
*On = Enable PHP error output*  
*Off = Disable PHP error output*

**SET_XDEBUG_REMOTE_IP**=10.0.2.2  
**SET_XDEBUG_REMOTE_PORT**=9000

**SET_NODE_PORT**=3000

**SET_CERT_COUNTRY**=MY  
**SET_CERT_STATE**=Selangor  
**SET_CERT_CITY**=Cyberjaya  
**SET_CERT_ORGANIZATION**=Vagrant  
**SET_CERT_COMMON_NAME**=(SET_HOST_FQDN)

**SETUP_NODE8**=0  
*Flag 1 = Installs Node 8*

**SETUP_BUILD**=0  
*Flag 1 = Installs build-essential*

**SETUP_PM2**=0  
*Flag 1 = Installs PM2 node service manager*

**SETUP_NODE_PROXY**=0  
*Flag 1 = Configure Node proxy pass (binds with NGINX)*

**SETUP_MYSQL**=0  
*Flag 1 = Installs MySQL database (unsets with MariaDB)*

**SETUP_MARIADB**=0  
*Flag 1 = Installs MariaDB database*

**SETUP_MONGODB**=0  
*Flag 1 = Installs MongoDB NoSQL database*

**SETUP_REDIS**=0  
*Flag 1 = Installs Redis key-value store*

**SETUP_BEANSTALKD**=0  
*Flag 1 = Installs Beanstalkd queue service*  
*May use QUEUE_DRIVER=beanstalkd in Laravel/Lumen .env config*

**SETUP_SUPERVISOR**=0  
*Flag 1 = Installs Supervisor process control*  
*Loops queue process in background if Laravel/Lumen installed*

**SETUP_APACHE**=0  
*Flag 1 = Installs Apache 2.4 httpd web server*

**SETUP_NGINX**=0  
*Flag 1 = Installs NGINX web server (unsets with Apache)*

**SETUP_PHP7FPM**=0  
*Flag 1 = Installs PHP7.1 FPM (binds with Apache / NGINX)*

**SETUP_PHP5FPM**=0  
*Flag 1 = Installs PHP5.6 FPM (binds with Apache / NGINX) (unsets with PHP7)*

**SETUP_HTTPS**=0  
*Flag 1 = Setup HTTPS with self-signed certs (binds with Apache / NGINX)*

**SETUP_PHP_EXT_XML**=0  
*Flag 1 = Installs PHP XML Extension (required by Laravel)*

**SETUP_PHP_EXT_MBSTRING**=0  
*Flag 1 = Installs PHP Mbstring Extension (required by Laravel & Lumen)*

**SETUP_PHP_EXT_MYSQL**=0  
*Flag 1 = Installs PHP MySQL Extension (required by Laravel & Lumen)*

**SETUP_PHP_EXT_CURL**=0  
*Flag 1 = Installs PHP cURL Extension*

**SETUP_PHP_EXT_REDIS**=0  
*Flag 1 = Installs PHP Redis Extension*

**SETUP_PHP_EXT_MONGODB**=0  
*Flag 1 = Installs PHP MongoDB Extension*

**SETUP_COMPOSER**=0  
*Flag 1 = Installs Composer*

**SETUP_XDEBUG**=0  
*Flag 1 = Installs & setup XDebug*

**SETUP_LARAVEL**=0  
*Flag 1 = Installs / setup Laravel*

**SETUP_LUMEN**=0  
*Flag 1 = Installs / setup Lumen*  
*Disabled if SETUP_LARAVEL=1*

**SETUP_PACKAGES_COMPOSER**=0  
*Flag 1 = Installs composer packages (with composer.json, without vendor folder)*

**SETUP_PACKAGES_NPM**=0  
*Flag 1 = Installs NPM packages (with package.json, without node_modules folder)*

**SETUP_WEBMIN**=1  
*Flag 1 = Installs Webmin Control Panel (includes Perl & Python dependencies)*

**SETUP_BASH**=1  
*Flag 1 = Adds command shortcuts & cd /vagrant on ssh login*

### Prerequisites ###

* Virtualbox installed
* Vagrant installed
* At least 3GB RAM

### Usage ###

1. Clone the project  
`git clone https://github.com/faisaladlin/vxenial.git myproject`
2. Navigate into project folder  
`cd myproject`
3. Edit Vagrantprovision.sh as necessary  
`vi Vagrantprovision.sh`
4. Provision & run the server  
`vagrant up`
5. Connect to the server  
`vagrant ssh`
6. Optional: Browse the web server from host  
http://192.168.33.10
7. Optional: Browse the web server (HTTPS) from host  
https://192.168.33.10  
Note: Self-signed certificate must be added into trusted list
8. Optional: Connect to the database from host  
`server : 192.168.33.10 | database : vagrant | user : root | password : vagrant`
9. Optional (node project): create project, install dependencies, run as service  
`(ssh into vagrant)`  
`npm init`  
`npm install express (if required)`  
`(create app.js)`  
`pm2 start app.js`

### Contributor(s) ###

* Faisal Adlin Addenan
