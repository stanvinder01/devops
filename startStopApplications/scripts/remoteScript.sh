#!/bin/bash
ARG_APPLICATION_TYPE=${ARG_APPLICATION_TYPE}
ARG_ACTION=${ARG_ACTION}

cat <<EOF
Kidaan vai tanvinder.....
ARG_APPLICATION_TYPE=${ARG_APPLICATION_TYPE}
ARG_ACTION=${ARG_ACTION}
EOF

stopProxyCMD(){
su - root -c "service httpd stop"
}
                                         
stopProxy() {
G_RESULT=`checkIfHTTPDIsRunning`
if [[ ${G_RESULT} -gt 0 ]]; then
 echo "Going to Stop HTTPD Service"
 stopProxyCMD
 sleep 5
 G_RESULT=`checkIfHTTPDIsRunning`
 echo "G_RESULT===${G_RESULT}"
 if [[ ${G_RESULT} -eq 0 ]]; then
  echo "HTTPD Service stopped successfully"
 else
  echo "Failed to Stop HTTPD Service.Exiting..."
  exit 1;
  fi
else
 echo "HTTPD Service is already Stopped"
fi

}

startProxyCMD(){
su - root -c "service httpd start"
}

startProxy() {
G_RESULT=`checkIfHTTPDIsRunning`
if [[ ${G_RESULT} -gt 0 ]]; then
 echo "HTTPD Service is already Started"
else
 echo "Going to Start HTTPD Service"
 startProxyCMD
 sleep 5
 G_RESULT=`checkIfHTTPDIsRunning`
 echo "G_RESULT===${G_RESULT}"
 if [[ ${G_RESULT} -gt 0 ]]; then
  echo "HTTPD Service started successfully"
 else
  echo "Failed to Start HTTPD Service.Exiting..."
  exit 1;
 fi
fi

}

restartProxy(){
stopProxy
startProxy
}

checkIfHTTPDIsRunning(){
local l_count=`ps -ef | grep httpd | grep -v grep | wc -l`
echo ${l_count}
}

stopTomcatCMD(){
su - root -c "service tomcat stop"
}

killTomcatCMD(){
su - root -c "kill $(ps aux | grep /usr/share/apache-tomcat | grep -v grep | awk '{print $2}')"
}

stopTomcat(){
 local l_counter=0
 local l_max_limit=3
 
G_RESULT=`checkIfTomcatIsRunning`
 echo "G_RESULT===${G_RESULT}"
 
 if [[ ${G_RESULT} -eq 0 ]]; then
	echo "Tomcat service is already stopped"
else
 while [ ${l_counter} -lt ${l_max_limit} ];
 do
 G_RESULT=`checkIfTomcatIsRunning`
 echo "G_RESULT===${G_RESULT}"
 if [[ ${G_RESULT} -gt 0 ]]; then
	echo "Going to Stop Tomcat Service"
	stopTomcatCMD
 else 
	break;
 fi
 echo "Sleeping for 10 sec"
 sleep 10
 echo "Before l_counter=$l_counter"

 l_counter=$((l_counter+1))
 echo "After l_counter=$l_counter"
 done
 
 echo "Going to kill Tomcat"
 killTomcatCMD
 echo "Sleeping for 10 sec"
 sleep 10
 G_RESULT=`checkIfTomcatIsRunning`
 echo "G_RESULT===${G_RESULT}"
  if [[ ${G_RESULT} -gt 0 ]]; then
  echo "Unable to stop Tomcat. Exiting..."
  exit 1;
  fi
  fi

}


startTomcatCMD(){
su - root -c "service tomcat start" 
}

startTomcat(){
G_RESULT=`checkIfTomcatIsRunning`
 echo "G_RESULT===${G_RESULT}"
  if [[ ${G_RESULT} -gt 0 ]]; then
	echo "Tomcat Service is already running"
  else
   echo "Going to Start Tomcat Service"
   startTomcatCMD  
   sleep 5
   G_RESULT=`checkIfTomcatIsRunning`
 echo "G_RESULT===${G_RESULT}"
 if [[ ${G_RESULT} -gt 0 ]]; then
	echo "Tomcat Service started successfully"
  else
   echo "Failed to Start Tomcat Service.Exiting..."
 exit 1;
  fi
   fi

 

}

restartTomcat(){
stopTomcat
startTomcat
} 

checkIfTomcatIsRunning(){
local l_count=`ps -ef | grep /usr/share/apache-tomcat | grep -v grep | wc -l`
echo ${l_count}
}

stopSchedulerCMD(){ 
sudo sh /opt/msb-scheduler/bin/scheduler.sh stop
}

stopScheduler(){
 G_RESULT=`checkIfSchedulerIsRunning`
 echo "G_RESULT===${G_RESULT}"
  if [[ ${G_RESULT} -gt 0 ]]; then
	echo "Going to Stop Scheduler Service"
	stopSchedulerCMD
	sleep 5
	G_RESULT=`checkIfSchedulerIsRunning`
	 echo "G_RESULT===${G_RESULT}"
	 if [[ ${G_RESULT} -eq 0 ]]; then
	echo "Scheduler Service stopped successfully"
  else
   echo "Failed to Stop Scheduler Service.Exiting..."
 exit 1;
  fi
  else
   echo "Scheduler Service is already Stopped"
  fi

}

startSchedulerCMD(){
sudo sh /opt/msb-scheduler/bin/scheduler.sh start
}

startScheduler(){
G_RESULT=`checkIfSchedulerIsRunning`
 echo "G_RESULT===${G_RESULT}"
  if [[ ${G_RESULT} -gt 0 ]]; then
	echo "Scheduler Service is already running"
  else
   echo "Going to Start Scheduler Service"
   startSchedulerCMD
      sleep 5
   G_RESULT=`checkIfSchedulerIsRunning`
 echo "G_RESULT===${G_RESULT}"
 if [[ ${G_RESULT} -gt 0 ]]; then
	echo "Scheduler Service started successfully"
  else
   echo "Failed to Start Scheduler Service.Exiting..."
 exit 1;
  fi
  fi
}

restartScheduler(){
stopScheduler
startScheduler
} 

checkIfSchedulerIsRunning(){
local l_count=`ps -ef | grep /opt/msb-scheduler | grep -v grep | wc -l`
echo ${l_count}
}

stopMysqlCMD(){
sudo service mysqld stop 
}
                                      
stopMysql() {
G_RESULT=`checkIfMysqlIsRunning`
if [[ ${G_RESULT} -gt 0 ]]; then
 echo "Going to Stop MYSQLD Service"
 stopMysqlCMD
 sleep 5
 G_RESULT=`checkIfMysqlIsRunning`
 echo "G_RESULT===${G_RESULT}"
 if [[ ${G_RESULT} -eq 0 ]]; then
  echo "MYSQLD Service stopped successfully"
 else
  echo "Failed to Stop MYSQLD Service.Exiting..."
  exit 1;
 fi
else
 echo "MYSQLD Service is already Stopped"
fi
}

startMysqlCMD(){
sudo service mysqld start 
}

startMysql() {
G_RESULT=`checkIfMysqlIsRunning`
if [[ ${G_RESULT} -gt 0 ]]; then
 echo "MYSQLD Service is already Started"
else
 echo "Going to Start MYSQLD Service"
 startMysqlCMD
 sleep 5
 G_RESULT=`checkIfMysqlIsRunning`
 echo "G_RESULT===${G_RESULT}"
 if [[ ${G_RESULT} -gt 0 ]]; then
  echo "MYSQLD Service started successfully"
 else
  echo "Failed to Start MYSQLD Service.Exiting..."
  exit 1;
 fi
fi
}


restartMysql(){
stopMysql
startMysql
}

checkIfMysqlIsRunning(){
local l_count=`ps -ef | grep mysqld | grep -v grep | wc -l`
echo ${l_count}
}

##############################################################################
#MAIN                                                                        #
############################################################################## 

if [[ ${ARG_APPLICATION_TYPE} == "PROXY" && ${ARG_ACTION} == "STOP" ]]; then
stopProxy
fi

if [[ ${ARG_APPLICATION_TYPE} == "PROXY" && ${ARG_ACTION} == "START" ]]; then
startProxy
fi

if [[ ${ARG_APPLICATION_TYPE} == "PROXY" && ${ARG_ACTION} == "RESTART" ]]; then
restartProxy
fi

if [[ ${ARG_APPLICATION_TYPE} == "TOMCAT" && ${ARG_ACTION} == "STOP" ]]; then
stopTomcat
fi

if [[ ${ARG_APPLICATION_TYPE} == "TOMCAT" && ${ARG_ACTION} == "START" ]]; then
startTomcat
fi

if [[ ${ARG_APPLICATION_TYPE} == "TOMCAT" && ${ARG_ACTION} == "RESTART" ]]; then
restartTomcat
fi

if [[ ${ARG_APPLICATION_TYPE} == "SCH" && ${ARG_ACTION} == "STOP" ]]; then
stopScheduler
fi

if [[ ${ARG_APPLICATION_TYPE} == "SCH" && ${ARG_ACTION} == "START" ]]; then
startScheduler
fi

if [[ ${ARG_APPLICATION_TYPE} == "SCH" && ${ARG_ACTION} == "RESTART" ]]; then
restartScheduler
fi

if [[ ${ARG_APPLICATION_TYPE} == "DB" && ${ARG_ACTION} == "STOP" ]]; then
stopMysql
fi

if [[ ${ARG_APPLICATION_TYPE} == "DB" && ${ARG_ACTION} == "START" ]]; then
startMysql
fi

if [[ ${ARG_APPLICATION_TYPE} == "DB" && ${ARG_ACTION} == "RESTART" ]]; then
restartMysql
fi

if [[ ${ARG_APPLICATION_TYPE} == "ALL" && ${ARG_ACTION} == "STOP" ]]; then
stopProxy
stopTomcat
stopScheduler
stopMysql
fi

if [[ ${ARG_APPLICATION_TYPE} == "ALL" && ${ARG_ACTION} == "START" ]]; then
startMysql
startScheduler
startTomcat
startProxy
fi

if [[ ${ARG_APPLICATION_TYPE} == "ALL" && ${ARG_ACTION} == "RESTART" ]]; then
stopProxy
stopTomcat
stopScheduler
stopMysql
startMysql
startScheduler
startTomcat
startProxy
fi
