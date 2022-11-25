FROM fedora:latest as BUILD_STAGE

# Install JDK 8
RUN dnf install -y java-17-openjdk

# Install Maven
RUN dnf install -y maven

# Copy files to TEMP directory
COPY pom.xml /tmp/
COPY src /tmp/src/

#Change working directory to TEMP
WORKDIR /tmp/

#Execute maven build
RUN mvn clean install package

#Copy build from TEMP to /
RUN cp target/snap-crescent-*.jar /snap-crescent.jar

#Change working directory to /
WORKDIR /

FROM node:latest
RUN apt install openjdk-17-jre-headless

# COPY compiled jar file to new image
COPY --from=BUILD_STAGE snap-crescent.jar .

# Deploy Build
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "snap-crescent.jar"]
