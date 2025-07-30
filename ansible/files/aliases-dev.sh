#!/bin/bash

cat << 'EOF' > /tmp/40-list-aliases
#!/bin/sh

Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
Reset='\033[0m'
LightCyan='\033[1;36m'
Green='\033[0;32m'

echo
echo "$Green ================================================================"
echo "$Reset"
echo "$LightCyan ______              ___ ______ _____ "
echo "$LightCyan |  _  \            / _ \| ___ \_   _|"
echo "$LightCyan | | | |_____   __ / /_\ \ |_/ / | | " 
echo "$LightCyan | | | / _ \ \ / / |  _  |  __/  | | " 
echo "$LightCyan | |/ /  __/\ V /  | | | | |    _| |_" 
echo "$LightCyan |___/ \___| \_/   \_| |_|_|    \___/" 
echo 
echo "$LightCyan Welcome to Dev API Servers, please note your pod and node number"
echo "$Reset"
echo "$Green Directories:"
echo "$Green Incoming FTP and email -- softlinked to /var/www/html/incoming"
echo "$Green S3FS mount --------------- /mnt/s3fs"
echo "$Reset"
echo "$LightCyan These aliases can be invoked from anywhere"
echo "$LightCyan api ----------------------- /var/www/html"
echo "$LightCyan incoming ------------------ incoming directory"
echo "$LightCyan archived ------------------ archive directory"
echo "$LightCyan logs ---------------------- logs directory"
echo "$LightCyan home ---------------------- re-displays this menu"
echo "$Green ================================================================"
echo "$LightCyan bcm ----------------------- run 'app/console app:bcm'"
echo "$LightCyan cmd ----------------------- run a app/console app:xxx command"
echo "$LightCyan sancheck ------------------ Generate SQL Query for sanitiy check incoming directory"
echo "$LightCyan qbosyncall ---------------- Sync all QBO Customers"
echo "$LightCyan backuprestore ------------- Backup Restore Instance"
echo "$Green ================================================================"
echo "$Reset"
EOF

