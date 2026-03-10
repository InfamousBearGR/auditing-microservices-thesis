# Build stage
FROM eclipse-temurin:21-jdk-alpine AS build

WORKDIR /app

# Install Gradle to bootstrap the wrapper jar
RUN apk add --no-cache wget unzip && \
    wget -q https://services.gradle.org/distributions/gradle-9.0.0-bin.zip -O /tmp/gradle.zip && \
    unzip -q /tmp/gradle.zip -d /opt && \
    rm /tmp/gradle.zip
ENV PATH="/opt/gradle-9.0.0/bin:${PATH}"

# Copy Gradle wrapper and build files
COPY gradle ./gradle
COPY gradlew settings.gradle build.gradle gradle.properties ./

# Download dependencies
RUN gradle dependencies --no-daemon

# Copy source code and build
COPY src ./src
RUN gradle bootJar -x test --no-daemon

# Runtime stage
FROM eclipse-temurin:21-jre-alpine

WORKDIR /app

# Copy the fat JAR from build stage
COPY --from=build /app/build/libs/*.jar /app/sse-bridge.jar

EXPOSE 8080

# Run the application
CMD ["java", "-jar", "/app/sse-bridge.jar"]
