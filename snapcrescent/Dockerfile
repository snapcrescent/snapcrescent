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
RUN cp target/snapcrescent-*.jar /snapcrescent.jar

#Change working directory to /
WORKDIR /

FROM ubuntu:latest
# install ffmpeg
RUN apt update
RUN apt install -y openjdk-17-jre
RUN apt-get -y install ffmpeg
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/*

# COPY compiled jar file to new image
COPY --from=BUILD_STAGE snapcrescent.jar .

# Deploy Build
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "snapcrescent.jar"]
