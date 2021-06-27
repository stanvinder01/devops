#!/bin/bash
#Exit on error
trap 'exit' ERR

# Jenkins file directory
REMOTE_BASE_DIR=$1

# Final Directory
AUTOMATION_DIR=$2

echo 'Removing old files'
# Remove everything from automation directory
rm -rf ${AUTOMATION_DIR}/docker

rm -rf ${AUTOMATION_DIR}/autobot

rm -rf ${AUTOMATION_DIR}/mounted/nfs/msb/tmp/pdfs

rm -rf ${AUTOMATION_DIR}/mounted/autobot

rm -rf ${AUTOMATION_DIR}/mounted/log
echo 'Removed old files'

# Create directories
mkdir -p ${AUTOMATION_DIR}/docker

mkdir -p ${AUTOMATION_DIR}/autobot

# Copy from Jenkins to automation directory
echo 'Copy compose files from temp directory'

cp -a ${REMOTE_BASE_DIR}/autobot/docker/* ${AUTOMATION_DIR}/docker/
cp -f ${REMOTE_BASE_DIR}/autobot/docker/.env ${AUTOMATION_DIR}/docker/

echo 'Copied compose files from temp directory'

echo 'Stopping all container(s)'
while read CONTAINER_ID
do
  if [ ! -z "$CONTAINER_ID" ]
  then
    echo "Stopping container with id: $CONTAINER_ID"
    docker stop $CONTAINER_ID
  fi
done<< EOF
$(docker ps -aq)
EOF

docker system prune -f --volumes

cd ${AUTOMATION_DIR}/docker

docker-compose -f docker-compose-autobot.yml pull

docker system prune -f --volumes

docker network inspect msb-automation-network &>/dev/null || docker network create --driver bridge msb-automation-network

echo 'Starting DB'
docker-compose -f docker-compose-db.yml -p mysql up -d


echo 'Copying webapp'

rm -rf ${AUTOMATION_DIR}/docker/webapps

mkdir -p ${AUTOMATION_DIR}/docker/webapps

cp -f ${REMOTE_BASE_DIR}/app/mysignaturebook.war ${AUTOMATION_DIR}/docker/webapps/mysignaturebook.war

echo 'Done'
