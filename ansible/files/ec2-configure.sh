#!/bin/bash

# ENV=$1
# EMAIL=$2

# Set up PECL
printf "\n" | pecl install inotify-2.0.0
printf "\n" | pecl install oauth-2.0.3
printf "\n" | pecl install redis-4.3.0
printf "\n" | pecl install mongodb-1.4.4

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

# Bare minimum creation of a webserver to have something to host an info.php file
cat << 'EOF' > /home/ubuntu/default
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
mv -f /home/ubuntu/default /etc/nginx/sites-available/default

# Adjust nginx config to environment
cat << 'EOF' > /home/ubuntu/nginx
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
mv -f /home/ubuntu/nginx /etc/nginx/nginx.conf

service nginx reload
cat << 'EOF' > /home/ubuntu/info.php
<?php phpinfo(); ?>
EOF

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
echo "$2.efs.us-east-1.amazonaws.com:/ /mnt/efs nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 0 0" >> /etc/fstab

mount -a

# Enable login for www-data user 
chsh -s /bin/bash www-data

# give www-data mail perms
adduser www-data mail

# Install FluentD
curl -L https://toolbelt.treasuredata.com/sh/install-ubuntu-bionic-td-agent3.sh | sh
sudo systemctl enable td-agent.service
sudo systemctl stop td-agent.service


# Install Signal FX agent
curl -sSL https://dl.signalfx.com/signalfx-agent.sh > /tmp/signalfx-agent.sh
sudo sh /tmp/signalfx-agent.sh --realm us1 -- $3


# Confirm Signal FX installation
sudo signalfx-agent status

# Make sure signatures have had time to load for Clamav
service clamav-freshclam stop
freshclam
service clamav-freshclam start
service clamav-daemon start


exit 0