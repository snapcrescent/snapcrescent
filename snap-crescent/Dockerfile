FROM openjdk:11.0.7-jre-slim
ADD target/snap-crescent-*.jar /snap-crescent.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "-Dspring.profiles.active=${ENV}", "snap-crescent.jar"]
