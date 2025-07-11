# Use a lightweight JRE base image
FROM eclipse-temurin:17-jre

# Set working directory
WORKDIR /app

# Copy the JAR file into the container
COPY target/demo-ivr-0.0.1-SNAPSHOT.jar app.jar

# Set the startup command
ENTRYPOINT ["java", "-jar", "app.jar"]
