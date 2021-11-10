#!/bin/bash

#Basic variables
G_SYSLOG_DATE_FORMAT="+%b %d %Y %H:%M:%S"
G_PROGRAM_NAME=`basename $0`

G_CATCH_EARROR_CODE=""

#Function to log messages
log(){
local l_message=$1
echo -e "[`date "$G_SYSLOG_DATE_FORMAT"`] ${l_message}"
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


echo "===Update the OS======="
sudo yum update -y
G_CATCH_EARROR_CODE=$?
throwErrorAndExit ${G_CATCH_EARROR_CODE} "Failed at line number: ${LINENO} "
log "=================================================================================="

echo "=====Download epel repo====="
wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
G_CATCH_EARROR_CODE=$?
throwErrorAndExit ${G_CATCH_EARROR_CODE} "Failed at line number: ${LINENO} "
log "=================================================================================="

echo "=========Install epel repository============"
sudo yum install epel-release-latest-7.noarch.rpm -y
G_CATCH_EARROR_CODE=$?
throwErrorAndExit ${G_CATCH_EARROR_CODE} "Failed at line number: ${LINENO} "
log "=================================================================================="

echo "========Update epel repository============"
sudo yum update -y
G_CATCH_EARROR_CODE=$?
throwErrorAndExit ${G_CATCH_EARROR_CODE} "Failed at line number: ${LINENO} "
log "=================================================================================="

echo "=====Install all individual packages inside the repository======"
sudo yum install git python python-devel python-pip openssl ansible -y
G_CATCH_EARROR_CODE=$?
throwErrorAndExit ${G_CATCH_EARROR_CODE} "Failed at line number: ${LINENO} "
log "=================================================================================="

echo "=====Verify Version of Ansible====="
sudo ansible --version
G_CATCH_EARROR_CODE=$?
throwErrorAndExit ${G_CATCH_EARROR_CODE} "Failed at line number: ${LINENO} "
log "=================================================================================="

echo "=====Import Elasticsearch ansible role======="
sudo ansible-galaxy install elastic.elasticsearch,v7.13.3
G_CATCH_EARROR_CODE=$?
throwErrorAndExit ${G_CATCH_EARROR_CODE} "Failed at line number: ${LINENO} "
log "=================================================================================="


