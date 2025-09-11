# Use a lightweight JRE image for smaller size
FROM eclipse-temurin:17-jre-jammy

# Set working directory inside container
WORKDIR /app

# Copy the built JAR file from your local machine into the container
COPY target/*.jar app.jar

# Expose Spring Boot default port
EXPOSE 8080

# Command to run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
