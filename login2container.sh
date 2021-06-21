#!/bin/bash
#This script allows you to login to Docker Container Shell
# Assumption :
#  The default shell of container is "/bin/sh"
# Create a soft link
# ln -s /home/scripts/login2container.sh /bin/msb-l2c

clear
docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Status}}"
echo -e "\n\n"
echo -n "Which Container to login. Select Container Name or ID and press [ENTER] or CTRL+C to exit: "
read G_CONTAINER

G_CONTAINER_ID=`docker ps --format "table {{.ID}}\t{{.Names}}" |  grep ${G_CONTAINER} | awk '{print $1}'`
G_CONTAINER_NAME=`docker ps --format "table {{.ID}}\t{{.Names}}" |  grep ${G_CONTAINER} | awk '{print $2}'`

echo -e "\n\n"
echo -e "Loging Into the container shell..."
echo "Container ID = ${G_CONTAINER_ID}"
echo "Container Name = ${G_CONTAINER_NAME}"
echo -e "\n\n"
docker exec -it ${G_CONTAINER} /bin/sh