#!/bin/bash
#
# Stefan Meissner (sme)
#
# Backup each mysql databases into a different file and add it to an archiv
#
# Usage: create_mysql_backup [ -o output_dir ]
#                
#       -o [output_dir] optional the output directory where to put the files
#       -z gzip enabled
#
# based on the solution by Daniel Verner (http://carrotplant.com) 

PROG_NAME=$(basename $0)
USER="backup user"
PASSWORD="backup user pw"
OUTPUTDIR=${PWD}
GZIP_ENABLED=0

MYSQLDUMP="/usr/bin/mysqldump"
MYSQL="/usr/bin/mysql"

while getopts o:z OPTION
do
    case ${OPTION} in
        o) OUTPUTDIR=${OPTARG};;
        z) GZIP_ENABLED=1;;
        ?) echo "Usage: ${PROG_NAME} [ -o output_dir -z ]"
           exit 2;;
    esac
done

if [ ! -d "$OUTPUTDIR" ]; then
    mkdir -p $OUTPUTDIR
fi

# create archiv
date > date.index && tar cf "all_dbs.tar" date.index && rm date.index

# get a list of databases
databases=`$MYSQL --user=$USER --password=$PASSWORD -e "SHOW DATABASES;" | grep -Ev "(Database|information_schema)"`

# dump each database in turn
for db in $databases; do
        if [ $GZIP_ENABLED == 1 ]; then
                $MYSQLDUMP --user=$USER --password=$PASSWORD --single-transaction --quick --databases $db | gzip > "$db.gz" && tar rf "$OUTPUTDIR/all_dbs.tar" "$db.gz" && rm "$db.gz"
        else
                $MYSQLDUMP --user=$USER --password=$PASSWORD --single-transaction --quick --databases $db > "$db.sql" && tar rf "$OUTPUTDIR/all_dbs.tar" "$db.sql" && rm "$db.sql"
        fi
done
