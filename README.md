# Vagrant Xenial Canvas #

A configurable vagrant provisioning script for the stock ubuntu/xenial64 Vagrant box

### How it differs from the stock ubuntu/xenial64 script ###

* Runs Vagrantprovision.sh during provision
* Disables: vagrant box update checking
* Disables: writing vagrant console.log
* Sync Folder: . -> /vagrant (ubuntu:ubuntu user:group)
* Memory Allocation: 3GB (composer & npm tends to fail with less)
* SSH into /vagrant folder by default (instead of ~)

### Vagrantprovision.sh options ###

Feel free to customize Vagrantprovision.sh for your project.  
Available configurations (provisioning variables):

**SET_LOCALE**=en_US.UTF-8  
**SET_TIMEZONE**=Asia/Kuala_Lumpur

**SET_WWW_USER**=ubuntu  
**SET_WWW_GROUP**=ubuntu  
**SET_WWW_ROOT**=/vagrant

**SET_DB_NAME**=vagrant  
**SET_DB_PASSWORD**=vagrant  
**SET_DB_REMOTE_IP**=192.168.33.1

**SET_XDEBUG_REMOTE_IP**=10.0.2.2  
**SET_XDEBUG_REMOTE_PORT**=9000

**SETUP_NODE8**=0  
*Flag 1 = Installs Node 8*

**SETUP_BUILD**=0  
*Flag 1 = Installs build-essential (often required for node projects)*

**SETUP_MYSQL**=0  
*Flag 1 = Installs MySQL (with default db name & password set)*

**SETUP_MONGODB**=0  
*Flag 1 = Installs MongoDB NoSQL database*

**SETUP_REDIS**=0  
*Flag 1 = Installs Redis key-value store*

**SETUP_BEANSTALKD**=0  
*Flag 1 = Installs Beanstalkd queue service*

**SETUP_APACHE**=0  
*Flag 1 = Installs Apache 2.4 httpd web server*

**SETUP_PHP7FPM**=0  
*Flag 1 = Installs PHP7 FastCGI & binds with Apache httpd*

**SETUP_COMPOSER**=0  
*Flag 1 = Installs Composer*

**SETUP_XDEBUG**=0  
*Flag 1 = Installs & setup XDebug*

**SETUP_LARAVEL**=0  
*Flag 1 = Installs / setup Laravel (if dropped in laravel project root)*

**SETUP_BASH**=1  
*Flag 1 = Adds a few handy aliases in ~/.profile*

### Prerequisites ###

* Virtualbox installed
* Vagrant installed
* At least 4GB RAM

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
7. Optional: Connect to the database from host  
`server : 192.168.33.10 | database : vagrant | user : root | password : vagrant`

### Contributor(s) ###

* Faisal Adlin Addenan (project owner)

