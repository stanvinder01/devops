#!/bin/bash
#Exit on error
trap 'exit' ERR

#!/bin/bash
#Exit on error
trap 'exit' ERR

AUTOMATION_DIR=$1

BROWSER=$2

MODE=$3

RUN_ID=$4

CASE_IDS=$5

INSTANCE=$6

startNode() {
  for ((index=0;index<$INSTANCE;index++))
  do
    docker-compose -f docker-compose-node.yml -p selenium-node-$index up -d $1
    echo "Started $1 node $index"
  done
}

cd ${AUTOMATION_DIR}/docker
echo 'Starting Selenium Hub'
docker-compose -f docker-compose-hub.yml -p selenium-hub up -d

if [ $BROWSER == 'chrome' ]
then
  mkdir chrome
  cp docker-compose-autobot.yml ./chrome/
  cp .env ./chrome/.env
  startNode 'chrome'
fi

if [ $BROWSER == 'mozilla' ]
then
  mkdir mozilla
  cp docker-compose-autobot.yml ./mozilla/
  cp .env ./mozilla/.env
  startNode 'mozilla'
fi

cd ${AUTOMATION_DIR}/docker

echo 'Starting web app'
docker-compose -f docker-compose-tomcat.yml -p tomcat up -d

# Wait for server to be up
sleep 60s

attempt_counter=0
max_attempts=10

until $(curl --output /dev/null --silent --head --fail http://localhost:8080/mysignaturebook/msbapi/public/alive); do
    if [ ${attempt_counter} -eq ${max_attempts} ];then
      echo "Max attempts reached"
      exit 1
    fi

    printf '.'
    attempt_counter=$(($attempt_counter+1))
    sleep 30s
done

echo 'Server is up'

echo 'Starting automation now'

cd ${AUTOMATION_DIR}/docker/${BROWSER}

sed -i "s/^BROWSER=.*/BROWSER=$BROWSER/" ".env"
sed -i "s/^INSTANCE=.*/INSTANCE=$INSTANCE/" ".env"
sed -i "s/^MODE=.*/MODE=$MODE/" ".env"
sed -i "s/^RUN_ID=.*/RUN_ID=$RUN_ID/" ".env"
sed -i "s/^CASE_IDS=.*/CASE_IDS=$CASE_IDS/" ".env"

docker-compose -f docker-compose-autobot.yml -p autobot-$BROWSER up

echo 'Automation finished'

docker stop $(docker ps -aq)

docker system prune -f --volumes

