#!/bin/bash

# ENV=$1
# EMAIL=$2

# Set up PECL
printf "\n" | pecl install inotify-2.0.0
printf "\n" | pecl install oauth-2.0.3
printf "\n" | pecl install redis
printf "\n" | pecl install mongodb
printf "\n" | pecl install xdebug-2.8.0
printf "\n" | pecl install gmagick-2.0.5RC1

# Create redis conf
cat << 'EOF' > /etc/redis/redis.conf
# Redis configuration file example.

################################## NETWORK #####################################

protected-mode yes
port 6379
tcp-backlog 511
timeout 0
tcp-keepalive 300

################################# GENERAL #####################################

daemonize yes
supervised no
pidfile /var/run/redis/redis-server.pid
loglevel notice
logfile /var/log/redis/redis-server.log
databases 16
always-show-logo yes

################################ SNAPSHOTTING  ################################

save 900 1
save 300 10
save 60 10000
stop-writes-on-bgsave-error yes
rdbcompression yes
rdbchecksum yes
dbfilename dump.rdb
dir /var/lib/redis

################################# REPLICATION #################################

slave-serve-stale-data yes
slave-read-only yes
repl-diskless-sync no
repl-diskless-sync-delay 5
repl-disable-tcp-nodelay no
slave-priority 100

############################# LAZY FREEING ####################################

lazyfree-lazy-eviction no
lazyfree-lazy-expire no
lazyfree-lazy-server-del no
slave-lazy-flush no

############################## APPEND ONLY MODE ###############################

appendonly no
appendfilename "appendonly.aof"
appendfsync everysec
no-appendfsync-on-rewrite no
auto-aof-rewrite-percentage 100
auto-aof-rewrite-min-size 64mb
aof-load-truncated yes
aof-use-rdb-preamble no

################################ LUA SCRIPTING  ###############################

lua-time-limit 5000

################################## SLOW LOG ###################################

slowlog-max-len 128

################################ LATENCY MONITOR ##############################

latency-monitor-threshold 0

############################# EVENT NOTIFICATION ##############################

notify-keyspace-events ""

############################### ADVANCED CONFIG ###############################

hash-max-ziplist-entries 512
hash-max-ziplist-value 64
list-max-ziplist-size -2
list-compress-depth 0
set-max-intset-entries 512
zset-max-ziplist-entries 128
zset-max-ziplist-value 64
hll-sparse-max-bytes 3000
activerehashing yes
client-output-buffer-limit normal 0 0 0
client-output-buffer-limit slave 256mb 64mb 60
client-output-buffer-limit pubsub 32mb 8mb 60
hz 10
aof-rewrite-incremental-fsync yes

EOF

# Create PHP app.ini
cat << 'EOF' > /etc/php/7.3/mods-available/app.ini
#All of our timezones should be in UTC
date.timezone = UTC

# This will allow 50 PDFs up to 50MB to be uploaded
upload_max_filesize = 50M
max_file_uploads = 50

post_max_size = 200M

# Some calls require up to 5 min of execution
max_execution_time = 300

# Tom added this so that sqlite tests can run in parallel
variables_order = "EGPCS"

# Legacy variables from Security Upgrade on original AMI 

max_input_time = 300

# Fix for json_encode
precision = 10
serialize_precision = 10

EOF

# Create PHP app-cli.ini
cat << 'EOF' > /etc/php/7.3/mods-available/app-cli.ini

memory_limit = 2048M

EOF

# Create PHP app-fpm.ini
cat << 'EOF' > /etc/php/7.3/mods-available/app-fpm.ini

memory_limit = 512M
error_reporting = E_ALL & ~E_NOTICE & ~E_STRICT & ~E_DEPRECATED

EOF

# Create PHP xdebug.ini
cat << 'EOF' > /etc/php/7.3/mods-available/xdebug.ini 

zend_extension=xdebug.so
xdebug.remote_enable=1
xdebug.remote_port=9000
xdebug.remote_autostart=0
xdebug.remote_log=/tmp/xdebug.log
xdebug.profiler_enable=0
xdebug.profiler_append=1
xdebug.profiler_output_dir=/tmp
xdebug.idekey=docker
xdebug.remote_handler=dbgp
xdebug.profiler_output_name=cachegrind.out
xdebug.remote_connect_back=0
xdebug.remote_host=docker.host.internal

EOF

# Enable php7 xdebug CLI
phpenmod -v 7.3 -s cli xdebug

# Enable php7 xdebug FPM
phpenmod -v 7.3 -s fpm xdebug

# Bare minimum creation of a webserver to have something to host an info.php file
cat << 'EOF' > /tmp/default
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    root /var/www/html/web;
    index app.php
    server_name 127.0.0.1;

    location / {
        try_files $uri /app.php$is_args$args;
    }

    location ~ \.php$ {
        fastcgi_pass unix:/run/php/php7.3-fpm.sock;
        include snippets/fastcgi-php.conf;
        fastcgi_split_path_info ^(.+\.php)(/.*)$;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        fastcgi_param DOCUMENT_ROOT $realpath_root;
	    fastcgi_read_timeout 300;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF
mv -f /tmp/default /etc/nginx/sites-available/default

# Adjust nginx config to environment
cat << 'EOF' > /tmp/nginx
user www-data;
worker_processes auto;
pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;

events {
    worker_connections 1024;
}

http {
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    client_max_body_size 200m;
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2; # Dropping SSLv3, ref: POODLE
    ssl_prefer_server_ciphers on;
    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;
    gzip on;
    gzip_disable "msie6";
    include /etc/nginx/conf.d/*.conf;
    include /etc/nginx/sites-enabled/*;
}
EOF
mv -f /tmp/nginx /etc/nginx/nginx.conf

service nginx reload
cat << 'EOF' > /tmp/info.php
<?php phpinfo(); ?>
EOF

# Additional packages
# Removed deprecated tool download
mkdir -p /var/log/rex && \
mkdir rex && \
tar zxf rex_linux_amd64.tar.gz -C rex && \
mv rex/rex /usr/bin && \
rm -rf rex_linux_amd64.tar.gz rex

wget https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip && \
mkdir -p /var/log/ngrok && \
unzip ngrok-stable-linux-amd64.zip && \
mv ngrok /usr/bin && \
rm -f ngrok-stable-linux-amd64.zip

# Grants us the ability to cross-format diff xls, xlsx, xlsm, and ods files
# Only used in dev (at the moment)
wget https://github.com/na-ka-na/ExcelCompare/releases/download/0.6.1/ExcelCompare-0.6.1.zip && \
mkdir -p /var/www/html/java/lib/excel_cmp && \
unzip ExcelCompare-0.6.1.zip -d /var/www/html/java/lib/excel_cmp && \
chmod 744 /var/www/html/java/lib/excel_cmp/bin/excel_cmp && \
ln -s /var/www/html/java/lib/excel_cmp/bin/excel_cmp /usr/local/bin && \
rm -f ExcelCompare-0.6.1.zip

# Install MS fonts
echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections
apt-get install ttf-mscorefonts-installer -y -qq
fc-cache

#fix security restrictions of ImageMagick on 18.04
sed -i 's/<policy domain="coder" rights="none" pattern="PDF" \/>/<policy domain="coder" rights="read|write" pattern="PDF" \/>/g' /etc/ImageMagick-6/policy.xml

# Use AWS VPC NTP
sed -i -e 's/pool 0.ubuntu.pool.ntp.org iburst/server 169.254.169.123 prefer iburst/g' /etc/ntp.conf
sed -i -e 's/pool 1./#pool 1./g' /etc/ntp.conf
sed -i -e 's/pool 2./#pool 2./g' /etc/ntp.conf
sed -i -e 's/pool 3./#pool 3./g' /etc/ntp.conf
service ntp restart

# Install Rex
export GOPATH=/usr
# Removed deprecated tool installation

# remove ruby 2.5/rake if installed
apt purge libruby ruby rake -y -qq

# add repositories for bionic and bionic-updates
cat << EOF > /etc/apt/sources.list.d/bionic.list
deb http://archive.ubuntu.com/ubuntu/ bionic main
deb http://archive.ubuntu.com/ubuntu/ bionic-updates main
EOF

# prioritise ruby/rake from bionic repository
cat << EOF > /etc/apt/preferences.d/ruby-bionic

Package: ruby
Pin: release v=18.04, l=Ubuntu
Pin-Priority: 1024

Package: rake
Pin: release v=18.04, l=Ubuntu
Pin-Priority: 1024
EOF

# install ruby and dependent packages
apt update -qq
apt install ruby gdebi-core -y -qq

# Install nfs client on Ubuntu
apt-get install nfs-common -y -qq

# Create Folder /mnt/efs
mkdir -p /mnt/efs

# Mount EFS
# echo "$2.efs.us-east-1.amazonaws.com:/ /mnt/efs nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 0 0" >> /etc/fstab

mount -a

# Enable login for www-data user 
chsh -s /bin/bash www-data

# give www-data mail perms
adduser www-data mail

# Use AWS VPC NTP
sed -i -e 's/pool 0.ubuntu.pool.ntp.org iburst/server 169.254.169.123 prefer iburst/g' /etc/ntp.conf
sed -i -e 's/pool 1./#pool 1./g' /etc/ntp.conf
sed -i -e 's/pool 2./#pool 2./g' /etc/ntp.conf
sed -i -e 's/pool 3./#pool 3./g' /etc/ntp.conf
service ntp restart

# Make sure signatures have had time to load for Clamav
service clamav-freshclam stop
freshclam
service clamav-freshclam start
service clamav-daemon start


exit 0