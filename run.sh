#!/bin/bash

###############################################################################
#VARIABLE DECLARATION GOES HERE                                               #
###############################################################################

#INPUT ARGUMENTS
ARG_LOGS_FOR=${1,,} # APP | SCH
ARG_CLIENT_NAME=${2,,}
ARG_LOGFILE_DATE=${3} # 2019-12-01

# Global Variables
G_PROGRAM_NAME=`basename $0`

G_SYSLOG_DATE_FORMAT="+%b %d %Y %H:%M:%S"

G_SCRIPT_HOME="/home/servsupport/automation/emailAppLogs"
G_BIN_DIRECTORY="/home/servsupport/automation/common/bin"

G_PACKER_UTIL="${G_BIN_DIRECTORY}/packer"
G_TEMPLATE_DIR="${G_SCRIPT_HOME}templates/"
G_TEMPLATE_FILE="${G_TEMPLATE_DIR}emailAppLogs.json"
G_TEMPLATE_FILE_VARIABLES="${G_TEMPLATE_DIR}variables.json"


G_EMAIL_RECIEPIENTS="support@msbdocs"

G_APP_LOG_PATH="/var/log/msb"
G_SCHEDULER_LOG_PATH="/var/log/msb/scheduler"

G_APP_LOG_FILENAME="msb.log"
G_SCHEDULER_LOG_FILENAME="msbscheduler.log"

#Function to log messages
log(){
local l_message=$1
echo -e "[`date "$G_SYSLOG_DATE_FORMAT"`] ${l_message}"
}

sendEmail() {
local l_exitMessage=$1
echo "${ARG_CLIENT_NAME} \n ${l_exitMessage}" | mail -s "[LOG] App Logs for ${ARG_CLIENT_NAME}" ${G_EMAIL_RECIEPIENTS}
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



echo "This is the message body" | mutt -a "/var/log/msb/msb.log" -s "test_logs" -- support@msbdocs.com
