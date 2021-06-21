#!/bin/bash
#INPUT ARGUMENTS
ARG_CLIENT_NAME=${1^^}
ARG_APPLICATION_TYPE=${2^^} # PROXY | TOMCAT | DB | SCH | ALL
ARG_ACTION=${3^^} # RESTART | START | STOP 

# Global Variables
G_PROGRAM_NAME=`basename $0`
G_SYSLOG_DATE_FORMAT="+%b %d %Y %H:%M:%S"
G_SCRIPT_HOME="/home/servsupport/automation/startStopApplications"
G_BIN_DIRECTORY="/home/servsupport/automation/common/bin"
G_PACKER_UTIL="${G_BIN_DIRECTORY}/packer"
G_TEMPLATE_DIR="${G_SCRIPT_HOME}/templates/"
G_TEMPLATE_FILE="${G_TEMPLATE_DIR}startStopApplications.json"
G_TEMPLATE_FILE_VARIABLES="${G_TEMPLATE_DIR}variables.json"
G_EMAIL_RECIEPIENTS="suparn.bector@msbdocs.com tanvinder.singh@msbdocs.com"
G_CLIENT_NAMES_ARR="PFIZER ICON APP APP2 MASAOOD APOLLO ATLN ROCHEi ALKEM"
G_APPLICATION_TYPE_ARR="PROXY TOMCAT DB SCH ALL"
G_ACTION_ARR="RESTART START STOP"

###############################################################################
#FUNCTION DEFINITION AND DECLARATION GOES HERE                                #
###############################################################################
# Function to print USAGE
usage() {
echo -e "\n"
cat <<EOF
Usage: $0 <Client Name> <Application Type> <Action>

Where:
<Client Name> : APOLLO | PFIZER | ROCHE | ICON | ATLN | MASAOOD | APP | APP2 | ALKEM
<Application Type> : PROXY | TOMCAT | DB | SCH | ALL
<Action> : RESTART | START | STOP 

Example:
$0 PFIZER TOMCAT START

EOF
log "=========END==========="
exit 1;
}

#Function to log messages
log(){
local l_message=$1
echo -e "[`date "$G_SYSLOG_DATE_FORMAT"`] ${l_message}"
}


# Function to check if Variable is Empty or Not
hasValue()
{
local var="$1"
local errorMessage="$2"
local returnVal=-1
# Return true if:
# 1.    var is a null string ("" as empty string)
# 2.    var has got only spaces
if [[ -z "$var" ]];then
 returnVal=1
elif [[ -z "${var// }" ]]; then
 returnVal=1
elif [[ "${var// }" = "null" ]]; then
 returnVal=1
else
 returnVal=0
fi
if [[ ${returnVal} -gt 0 ]]; then
 log "Error: ${errorMessage}"
 log "=========END==========="
 exit 1;
fi
}


sendEmail() {
local l_email_body=$1
local l_email_subject=$2
echo " Client Name ${ARG_CLIENT_NAME} \n Application Type ${ARG_APPLICATION_TYPE} \n Action Performed ${ARG_ACTION}" | mail -s "${l_email_subject}" ${G_EMAIL_RECIEPIENTS}
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
 sendEmail ${l_exitMessage} "Error: ${l_exitMessage}"
 log "=========END==========="
 exit ${l_exitCode};
fi
}

# Function
#  Parameter 1 Array Of Elements
#  Parameter 2 is text to search in Array.
# Returns
# 0 : If Search String exists in Array
# 1 : IF Search String doesn't exists in Array
arrayContainsElement() {
eval l_array=("$(echo '${'$1'[@]}')")
local l_search_value=$2
if [[ "${l_array[@]}" =~ "${l_search_value}" ]]; then
 return 0;
else
 return 1;
fi
}


# Function to read deployAppAndEAI.json file and initialize variables.
fetchVariableFromJsonFile(){
local l_client_name=$1
local l_application_type=${2}
local l_action_type=${3}

G_OS_USERNAME=`cat ${G_TEMPLATE_FILE} | jq -s .[0].${l_client_name}.${l_application_type}.USERNAME | sed 's/\"//g'`
hasValue "${G_OS_USERNAME}" "Missing USERNAME value. It must be set in JSON file $G_TEMPLATE_FILE."

G_OS_PASSWORD=`cat ${G_TEMPLATE_FILE} | jq -s .[0].${l_client_name}.${l_application_type}.PASSWORD | sed 's/\"//g'`
hasValue "${G_OS_PASSWORD}" "Missing PASSWORD value. It must be set in JSON file $G_TEMPLATE_FILE."

G_OS_HOSTNAME=`cat ${G_TEMPLATE_FILE} | jq -s .[0].${l_client_name}.${l_application_type}.HOSTNAME | sed 's/\"//g'`
hasValue "${G_OS_HOSTNAME}" "Missing HOSTNAME value. It must be set in JSON file $G_TEMPLATE_FILE."

G_SSH_PORT=`cat ${G_TEMPLATE_FILE} | jq -s .[0].${l_client_name}.${l_application_type}.PORT | sed 's/\"//g'`
hasValue "${G_SSH_PORT}" "Missing PORT value. It must be set in JSON file $G_TEMPLATE_FILE."
}

runRemoteScript(){
log "${G_PACKER_UTIL} build -only BUILD-START-STOP-APPS -var ssh_host=${G_OS_HOSTNAME} -var ssh_username=${G_OS_USERNAME} -var ssh_password=${G_OS_PASSWORD} -var ssh_port=${G_SSH_PORT} -var ARG_APPLICATION_TYPE=${ARG_APPLICATION_TYPE} -var ARG_ACTION=${ARG_ACTION} ${G_TEMPLATE_FILE_VARIABLES}"
${G_PACKER_UTIL} build -only BUILD-START-STOP-APPS -var ssh_host=${G_OS_HOSTNAME} -var ssh_username=${G_OS_USERNAME} -var ssh_password=${G_OS_PASSWORD} -var ssh_port=${G_SSH_PORT} -var ARG_APPLICATION_TYPE=${ARG_APPLICATION_TYPE} -var ARG_ACTION=${ARG_ACTION} ${G_TEMPLATE_FILE_VARIABLES}


}

##############################################################################
#MAIN                                                                        #
##############################################################################
log "=========MAIN START==========="

if [[ $# -ne 3 ]]; then
 log "Not enough arguments passed."
 usage
fi


if [[ -z ${ARG_CLIENT_NAME} ]]; then
 log "CLIENT_NAME cannot be EMPTY"
 usage
fi

if [[ -z ${ARG_APPLICATION_TYPE} ]]; then
 log "ARG_APPLICATION_TYPE cannot be EMPTY"
 usage
fi

if [[ -z ${ARG_ACTION} ]]; then
 log "ARG_ACTION cannot be EMPTY"
 usage
fi

if [[ ${#G_CLIENT_NAMES_ARR[*]} -eq 0 ]]; then
 throwErrorAndExit 1 "Array with CLIENT NAMES value is EMPTY."
fi

arrayContainsElement G_CLIENT_NAMES_ARR $ARG_CLIENT_NAME
G_RESULT=$?
if [[ $G_RESULT -gt 0 ]]; then
 log "INVALID Client Name"
 usage
fi


if [[ ${#G_APPLICATION_TYPE_ARR[*]} -eq 0 ]]; then
 throwErrorAndExit 1 "Array with Application Name value is EMPTY."
fi

arrayContainsElement G_APPLICATION_TYPE_ARR $ARG_APPLICATION_TYPE
G_RESULT=$?
if [[ $G_RESULT -gt 0 ]]; then
 log "INVALID Application Type"
 usage
fi

if [[ ${#G_ACTION_ARR[*]} -eq 0 ]]; then
 throwErrorAndExit 1 "Array with Action Name value is EMPTY."
fi

arrayContainsElement G_ACTION_ARR $ARG_ACTION
G_RESULT=$?
if [[ $G_RESULT -gt 0 ]]; then
 log "INVALID Action Type"
 usage
fi


if [[ "${ARG_APPLICATION_TYPE}" == "ALL" ]]; then
ARG_APPLICATION_TYPE=DB
fetchVariableFromJsonFile ${ARG_CLIENT_NAME} "DB" ${ARG_ACTION}
runRemoteScript

ARG_APPLICATION_TYPE=TOMCAT
fetchVariableFromJsonFile ${ARG_CLIENT_NAME} "TOMCAT" ${ARG_ACTION}
runRemoteScript

ARG_APPLICATION_TYPE=SCH
fetchVariableFromJsonFile ${ARG_CLIENT_NAME} "SCH" ${ARG_ACTION}
runRemoteScript

ARG_APPLICATION_TYPE=PROXY
fetchVariableFromJsonFile ${ARG_CLIENT_NAME} "PROXY" ${ARG_ACTION}
runRemoteScript

else

fetchVariableFromJsonFile ${ARG_CLIENT_NAME} ${ARG_APPLICATION_TYPE} ${ARG_ACTION}
runRemoteScript
fi


log "=========END==========="
