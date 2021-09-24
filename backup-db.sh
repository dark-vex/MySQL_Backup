#!/bin/bash
# This script creates a dump of all MySQL Databases
# Author: Daniele De Lorenzi daniele.delorenzi [at] fastnetserv.net

# Path to log file
LOGFILE="/var/log/backup-db.log"

# Function for sending email
send_mail(){
/usr/bin/sendemail -t backup@domain.tld -f sender@domain.tld -u sender_username -m Report -s 192.168.1.2 -a /var/log/backup-db.log -xu "sender@domain.tld" -xp "sender_pwd"
}

# MySQL Backup destination dir
DESTINATION_DIR="/mnt/backup"

# Mount point
MOUNT="/mnt/backup"

# MySQL Backup
USER="<INSERT-USER>"
PASSWORD="<INSERT-USER-PWD>"

DATABASES=`mysql --user=$USER --password=$PASSWORD -e "SHOW DATABASES;" | tr -d "| " | grep -v Database | grep -v performance_schema`

# Check the mountpoint
if grep -qs "$MOUNT" /proc/mounts; then
  echo "`date +%Y-%m-%d` $MOUNT It's already mounted." >> $LOGFILE
else
  echo "`date +%Y-%m-%d` $MOUNT It's not mounted. Trying.." >> $LOGFILE
  mount "$MOUNT"
  if [ $? -eq 0 ]; then
   echo "`date +%Y-%m-%d` Mount success!" >> $LOGFILE
  else
   # Exit and send an email in case the mount fails
   echo "`date +%Y-%m-%d` Something went wrong with the mount..." >> $LOGFILE
   send_mail
   exit 1
  fi
fi

for DB in $DATABASES; do
    if [[ "$DB" != "information_schema" ]] && [[ "$DB" != _* ]] ; then
        echo "`date +%Y-%m-%d` Dumping database: $DB" >> $LOGFILE
                mysqldump --lock-tables -h localhost --user=$USER --password=$PASSWORD --databases $DB > $DESTINATION_DIR/`date +%Y%m%d`.$DB.sql
        gzip $TO/`date +%Y%m%d`.$DB.sql
    fi
done
send_mail
exit 0
