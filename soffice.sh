#!/bin/bash

#INPUT ARGUMENTS
ARG_CLIENT_NAME=$1
ARG_URL=$2

#Basic variables
G_SYSLOG_DATE_FORMAT="+%b %d %Y %H:%M:%S"
G_PROGRAM_NAME=`basename $0`
G_RECIPIENTS="tanvinder.singh@msbdocs.com"
G_THRESHOLD="200"

#Function Goes Here

#Function to print USAGE
usage() {
echo -e "\n"
cat <<EOF
Usage: $0 <Client Name> <URL> 

Where:
<Client Name> : test 
<URL> : test.msbdocs.com
Example:
$0 test test.msbdocs.com 

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
echo -e "${ARG_CLIENT_NAME} ${ARG_URL} \n ${l_exitMessage}" | mail -s "[ERROR] Soffice process critical" ${G_RECIPIENTS}
}

checkHowManysOfficeProcessIsRunning(){
local l_count=`ps -eo pid,etimes,cmd | grep soffice | grep -v grep |  awk '{if ($2 >= 1800) print $0}' | wc -l`
echo ${l_count}
}

checksoffice() {
G_RESULT=`checkHowManysOfficeProcessIsRunning`
if [[ ${G_RESULT} -lt ${G_THRESHOLD} ]]; then
 echo "SOFFICE is normal"
else
 echo "SOFFICE is critical"
 sendEmail "Soffice is critical"
fi
}

checkHowManysOfficeProcessIsWaitingForResources(){
local l_count_waiting=`ps axl | grep soffice | grep -v grep | awk '$10 ~ /D/' | wc -l`
local l_count_zombie=`ps axl | grep soffice | grep -v grep | awk '$10 ~ /Z/' | wc -l`
#echo "No. of processes in waiting state ${l_count_waiting}"
#echo "No. of processes in stale/zombie state ${l_count_zombie}"
l_count=$(( l_count_waiting + l_count_zombie ))
echo $l_count
}


checkstalesoffice() {
G_RESULT=`checkHowManysOfficeProcessIsWaitingForResources`

if [[ ${G_RESULT} -lt ${G_THRESHOLD} ]]; then
 echo "SOFFICE processes are normal"
else
 echo "SOFFICE processes are critical"
 sendEmail "Stale or Zombie soffice processes are waiting"
fi 
}
##############################################################################
#MAIN                                                                        #
##############################################################################
log "=========MAIN START==========="

if [[ $# -ne 2 ]]; then
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

if [[ "${ARG_CLIENT_NAME}" != "test" ]]; then
 log "INVALID Client Name"
 usage
fi

if [[ "${ARG_URL}" != "test.msbdocs.com" ]]; then
 log "INVALID URL"
 usage
fi

echo "======Total number of soffice processes running========="
ps -ef | grep soffice | grep -v grep | wc -l

checksoffice
checkstalesoffice