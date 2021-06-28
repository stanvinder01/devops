#!/bin/bash

#INPUT ARGUMENTS
ARG_CLIENT_NAME=${1,,}
ARG_URL=${2,,}
ARG_MYSQL_USERNAME=$3
ARG_PASSWORD=$4


#Basic variables
G_SYSLOG_DATE_FORMAT="+%b %d %Y %H:%M:%S"
G_PROGRAM_NAME=`basename $0`

G_MD5SUM_ORG_FILE=""
G_MD5SUM_S3_FILE=""
G_CATCH_EARROR_CODE=""

G_DATE=`date +'%d%m%Y%H%M%S'`
G_TMP_FOLDER="dump_archive_tables"

G_DATABASE="msb"

G_S3_BUCKET="s3://backup-${ARG_URL}/ARC_AUDIT_TABLES_DUMP/"
#G_S3_BUCKET="s3://${ARG_URL}/ARC_AUDIT_TABLES_DUMP/"


#Define our filenames
G_ZIP_FILENAME="dump_archive_tables-${G_DATE}.tar.gz"
G_RECIPIENTS="tanvinder.singh@msbdocs.com"



#Function Goes Here

#Function to print USAGE
usage() {
echo -e "\n"
cat <<EOF
Usage: $0 <Client Name> <URL> <DB Username> <DB Password>

Where:
<Client Name> : apollo | pfizer | roche | icon | atln | masaood | app | app2 
<URL> : esign.roche.com | masaood.msbdocs.com | atln.mysignaturebook.com | pfizer.mysignaturebook.com | app.mysignaturebook.com | app2.mysignaturebook.com | icon.mysignaturebook.com | apollo.mysignaturebook.com 
<DB Username> : dbamdin | root
<DB Password> : It is a secret
Example:
$0 roche esign.roche.com dbadmin xxxxxx

EOF
log "=========END==========="
exit 1;
}

#Function to log messages
log(){
local l_message=$1
echo -e "[`date "$G_SYSLOG_DATE_FORMAT"`] ${l_message}"
}

sendEmail() {
local l_exitMessage=$1
echo "${ARG_CLIENT_NAME} ${ARG_URL} \n ${l_exitMessage}" | mail -s "[ERROR] Archive Dump Script" ${G_RECIPIENTS}
}

#Function
#Parameter 1 is the return code
#Parameter 2 is text to display on failure.
throwErrorAndExit()
{
local l_exitCode=$1
local l_exitMessage=$2

if [ "${l_exitCode}" -ne "0" ]; then
 echo "[${G_PROGRAM_NAME}]:ERROR: ${l_exitMessage}"
 sendEmail ${l_exitMessage}
 log "=========END==========="
 exit ${l_exitCode};
fi
}

##############################################################################
#MAIN                                                                        #
##############################################################################
log "=========MAIN START==========="

if [[ $# -ne 4 ]]; then
 log "Not enough arguments passed."
 usage
fi

if [[ -z ${ARG_CLIENT_NAME} ]]; then
 log "Client Name cannot be EMPTY"
 usage
fi

if [[ -z ${ARG_URL} ]]; then
 log "URL cannot be EMPTY"
 usage
fi

if [[ -z ${ARG_PASSWORD} ]]; then
 log "Password cannot be EMPTY"
 usage
fi

if [[ -z ${ARG_MYSQL_USERNAME} ]]; then
 log "DB Username cannot be EMPTY"
 usage
fi


if [[ "${ARG_CLIENT_NAME}" != "roche" ]] && [[ "${ARG_CLIENT_NAME}" != "apollo" ]] && [[ "${ARG_CLIENT_NAME}" != "pfizer" ]] && [[ "${ARG_CLIENT_NAME}" != "icon" ]] && [[ "${ARG_CLIENT_NAME}" != "app" ]] && [[ "${ARG_CLIENT_NAME}" != "app2" ]] && [[ "${ARG_CLIENT_NAME}" != "atln" ]] && [[ "${ARG_CLIENT_NAME}" != "masaood" ]]; then
 log "INVALID Client Name"
 usage
fi

if [[ "${ARG_URL}" != "esign.roche.com" ]] && [[ "${ARG_URL}" != "apollo.mysignaturebook.com" ]] && [[ "${ARG_URL}" != "pfizer.mysignaturebook.com" ]] && [[ "${ARG_URL}" != "icon.mysignaturebook.com" ]] && [[ "${ARG_URL}" != "app.mysignaturebook.com" ]] && [[ "${ARG_URL}" != "app2.mysignaturebook.com" ]] && [[ "${ARG_URL}" != "atln.mysignaturebook.com" ]] && [[ "${ARG_URL}" != "masaood.msbdocs.com" ]]; then
 log "INVALID URL"
 usage
fi

rm -rf ${G_TMP_FOLDER}
mkdir ${G_TMP_FOLDER}
G_CATCH_EARROR_CODE=$?
throwErrorAndExit ${G_CATCH_EARROR_CODE} "Failed at line number: ${LINENO} Message: Not able to create directory"

log "===DB SIZE BEFORE RUNNING THIS SCRIPT"
mysql -u$ARG_MYSQL_USERNAME -p$ARG_PASSWORD -N information_schema -e "SELECT table_schema AS \"Database\", ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS \"Size (MB)\" FROM information_schema.TABLES GROUP BY table_schema"
G_CATCH_EARROR_CODE=$?
throwErrorAndExit ${G_CATCH_EARROR_CODE} "Failed at line number: ${LINENO} "
log "=================================================================================="

# To create the file which which contains the procedure

cat > sql_file.sql << END_TEXT
call p_archive_all();
exit
END_TEXT

#Create the sql file which will call the procedure in db
log "=== Executing Procedure p_archive_all"
mysql -u$ARG_MYSQL_USERNAME -p$ARG_PASSWORD $G_DATABASE  < ./sql_file.sql
G_CATCH_EARROR_CODE=$?
throwErrorAndExit ${G_CATCH_EARROR_CODE} "Failed at line number: ${LINENO} Message: Not able to call procedure"
log "=================================================================================="

# Take the Dump
echo "ARG_PASSWORD=${ARG_PASSWORD}" > archiveTablesBackup.sh
mysql -u$ARG_MYSQL_USERNAME -p$ARG_PASSWORD -N information_schema -e "select concat('mysqldump -u$ARG_MYSQL_USERNAME' ,' -p$ARG_PASSWORD msb ',table_name, ' > ./$G_TMP_FOLDER/','$ARG_CLIENT_NAME' ,'_' ,table_name, '.sql') from tables where table_schema = 'msb' and table_name like 'arc_%'"  >> archiveTablesBackup.sh
G_CATCH_EARROR_CODE=$?
throwErrorAndExit ${G_CATCH_EARROR_CODE} "Failed at line number: ${LINENO} Message: Not able to take the dump"
log "=================================================================================="
sh archiveTablesBackup.sh

log "===CHECK THE FILE WITH ZERO BYTES"
 ls -ltr ./dump_archive_tables/
G_CATCH_EARROR_CODE=$?
throwErrorAndExit ${G_CATCH_EARROR_CODE} "Failed at line number: ${LINENO}"
log "=================================================================================="

log "=============="
tar -czvf ${G_ZIP_FILENAME} dump_archive_tables
G_CATCH_EARROR_CODE=$?
throwErrorAndExit ${G_CATCH_EARROR_CODE} "Failed at line number: ${LINENO} Message: Not able to make the zip"
log "=================================================================================="

G_MD5SUM_ORG_FILE=($(md5sum ${G_ZIP_FILENAME}))
G_CATCH_EARROR_CODE=$?
throwErrorAndExit ${G_CATCH_EARROR_CODE} "Failed at line number: ${LINENO} Message: Not able to make the zip"
log "=================================================================================="

log "===S3 COMMAND======"
/bin/flock -n /tmp/s3lock.lck /bin/s3cmd put --server-side-encryption --storage-class=STANDARD_IA  ./${G_ZIP_FILENAME} ${G_S3_BUCKET}
G_CATCH_EARROR_CODE=$?
throwErrorAndExit ${G_CATCH_EARROR_CODE} "Failed at line number: ${LINENO} Message: S3 Failed."
log "=================================================================================="

log "=============="
log "=====test  ===s3cmd ls --list-md5 ${G_S3_BUCKET}/$G_ZIP_FILENAME | awk '{print $4}'"
G_MD5SUM_S3_FILE=`s3cmd ls --list-md5 {G_S3_BUCKET}$G_ZIP_FILENAME | awk '{print $4}'`
#log "====G_MD5SUM_ORG_FILE===${G_MD5SUM_ORG_FILE}====G_MD5SUM_S3_FILE===${G_MD5SUM_S3_FILE}"
log "====G_MD5SUM_ORG_FILE===${G_MD5SUM_ORG_FILE}"
log "====G_MD5SUM_S3_FILE===${G_MD5SUM_S3_FILE}"

if [[ ${G_MD5SUM_ORG_FILE} == ${G_MD5SUM_S3_FILE} ]]; then
log "MD5SUM Matches"
else
log "MD5SUM match failed. Exiting..."
throwErrorAndExit 1 "MD5SUM match failed. Exiting..."
fi

#Delete
# rm -f "$G_ZIP_FILENAME"

log "===DB SIZE AFTER RUNNING THIS SCRIPT"
mysql -u$ARG_MYSQL_USERNAME -p$ARG_PASSWORD -N information_schema -e "SELECT table_schema AS \"Database\", ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS \"Size (MB)\" FROM information_schema.TABLES GROUP BY table_schema"
G_CATCH_EARROR_CODE=$?
throwErrorAndExit ${G_CATCH_EARROR_CODE} "Failed at line number: ${LINENO} "
log "=================================================================================="
