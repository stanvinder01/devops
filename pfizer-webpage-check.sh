#!/bin/bash

checkIfTomcatIsRunning(){
local l_count=`ps -ef | grep /usr/share/apache-tomcat | grep -v grep | wc -l`
echo ${l_count}
}

stopTomcatCMD(){
sudo service tomcat stop
}

killTomcatCMD(){
sudo kill $(ps aux | grep /usr/share/apache-tomcat | grep -v grep | awk '{print $2}')
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
sudo service tomcat start
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


echo "=====checking the status of webpage====="
HTTPS_STATUS=`lynx -head -source https://pfizer.msbdocs.com | head -1 | awk '{print $2}'`

echo "$HTTPS_STATUS"

echo "====executing the function======"
 if [[ "$HTTPS_STATUS" = "503"  ]]; then
      echo "webpage is DOWN"
      restartTomcat
 elif [[ "$HTTPS_STATUS" = "504" ]]; then
      echo "webpage is DOWN"
      restartTomcat
 else
  echo "Webpage is normal"

 fi