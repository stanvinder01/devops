#Use jre alpine for reduced size - https://hub.docker.com/r/adoptopenjdk/openjdk11/
#Use Springboot multi stage build with layered images for better optimized build with caching
# refer here - https://www.baeldung.com/docker-layers-spring-boot
FROM  adoptopenjdk/openjdk11-openj9:jre-11.0.10_9_openj9-0.24.0-alpine as transformer
WORKDIR /application
ARG JAR_FILE=target/*.jar
COPY ${JAR_FILE} application.jar
RUN java -Djarmode=layertools -jar application.jar list
RUN java -Djarmode=layertools -jar application.jar extract

# Second stage
FROM nrgdigitalcr.azurecr.io/nrg/spring-boot-tomcat-openjdk:jre-11-openj9-alpine
WORKDIR /app

#Using multi stage layered builds
COPY --chown=5050:5050 --from=transformer /application/dependencies/ ./
COPY --chown=5050:5050 --from=transformer /application/snapshot-dependencies/ ./
COPY --chown=5050:5050 --from=transformer /application/spring-boot-loader/ ./
COPY --chown=5050:5050 --from=transformer /application/application/ ./

# https://spring.io/guides/gs/spring-boot-docker/
# Entrypoint to app 
ENTRYPOINT ["java", "org.springframework.boot.loader.JarLauncher"]
