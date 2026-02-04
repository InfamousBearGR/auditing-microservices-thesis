# Build stage
FROM eclipse-temurin:21-jdk-alpine AS build

WORKDIR /app

# Copy Gradle wrapper and build files
COPY gradle ./gradle
COPY gradlew settings.gradle build.gradle gradle.properties ./

# Download dependencies
RUN ./gradlew dependencies --no-daemon

# Copy source code and build
COPY src ./src
RUN ./gradlew bootJar -x test --no-daemon

# Runtime stage
FROM eclipse-temurin:21-jre-alpine

WORKDIR /app

# Copy the fat JAR from build stage
COPY --from=build /app/build/libs/*.jar /app/sse-bridge.jar

EXPOSE 8080

# Run the application
CMD ["java", "-jar", "/app/sse-bridge.jar"]
