1. Change required values in .env file

2. To create bridge network for services
docker network create msb-automation-network

3. To run DB
docker-compose -f docker-compose-db.yml -p mysql up -d

4. To run HUB
docker-compose -f docker-compose-hub.yml -p selenium-hub up -d

5. To run chrome Node
docker-compose -f docker-compose-node.yml -p selenium-node up -d chrome

6. To run mozilla Node
docker-compose -f docker-compose-node.yml -p selenium-node up -d mozilla

7. To run tomcat
docker-compose -f docker-compose-tomcat.yml -p tomcat up -d

8. To run autobot
docker-compose -f docker-compose-autobot.yml -p autobot up -d
