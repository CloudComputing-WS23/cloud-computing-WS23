FROM eclipse-temurin:17
WORKDIR workspace
ARG JAR_FILE=build/libs/*.jar
COPY ${JAR_FILE} dispatch-service.jar
ENTRYPOINT ["java", "-jar", "dispatch-service.jar"]