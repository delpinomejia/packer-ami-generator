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
echo 
echo "$LightCyan ______              _    ___ ______ _____    "
echo "$LightCyan | ___ \            | |  / _ \| ___ \_   _|   "
echo "$LightCyan | |_/ / __ ___   __| | / /_\ \ |_/ / | |     "
echo "$LightCyan |  __/  __/ _ \ / _  | |  _  |  __/  | |     "
echo "$LightCyan | |  | | | (_) | (_| | | | | | |    _| |_    "
echo "$LightCyan \_|  |_|  \___/ \__,_| \_| |_|_|    \___/    " 
echo 
echo "$LightCyan Welcome to Sage API Servers, please note your pod and node number"
echo "$Reset"
echo "$Green Directories:"
echo "$Green Incoming FTP and email -- softlinked to /var/www/html/incoming"
echo "$Green NFS mount --------------- /mnt/nfs"
echo "$Reset"
echo "$LightCyan These aliases can be invoked from anywhere"
echo "$LightCyan home ---------------------- re-dispays this menu"
echo "$LightCyan API ----------------------- /var/www/html"
echo "$LightCyan Incoming ------------------ incoming directory"
echo "$LightCyan Archived ------------------ archive directory"
echo "$LightCyan Logs ---------------------- logs directory"
echo "$Reset"
echo "$Green ================================================================"
echo "$LightCyan bcm ----------------------- run 'app/console app:bcm'"
echo "$LightCyan cmd ----------------------- run a app/console app:xxx command"
echo "$LightCyan sancheck ------------------ Generate SQL Query for sanitiy check incoming directory"
echo "$LightCyan qbosyncall ---------------- Sync all QBO Customers"
echo "$LightCyan backuprestore ------------- Backup Restore Instance"
echo "$Green ================================================================"
echo "$Reset"
EOF

