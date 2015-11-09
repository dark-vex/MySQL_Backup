#!/bin/bash
#It creates a dump of MySQL Databases
#Author: Daniele De Lorenzi daniele.delorenzi [at] fastnetserv.net

#Path to log file
logfile=/var/log/backup-db.log
#Function for sending email
send_mail(){
/usr/bin/sendemail -t backup@domain.tld -f sender@domain.tld -u sender_username -m Report -s 192.168.1.2 -a /var/log/backup-db.log -xu "sender@domain.tld" -xp "sender_pwd"
}

#MySQL Backup
USER="<INSERT-USER>"
PASSWORD="<INSERT-USER-PWD>"

databases=`mysql --user=$USER --password=$PASSWORD -e "SHOW DATABASES;" | tr -d "| " | grep -v Database`

for db in $databases; do
    if [[ "$db" != "information_schema" ]] && [[ "$db" != _* ]] ; then
        echo $date "Dumping database: $db" >> $logfile
                mysqldump --lock-tables -h localhost --user=$USER --password=$PASSWORD --databases $db > $TO/`date +%Y%m%d`.$db.sql
        gzip $TO/`date +%Y%m%d`.$db.sql
    fi
done
send_mail
exit 0
