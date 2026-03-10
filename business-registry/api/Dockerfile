# Build stage
FROM gradle:8.5-jdk21-alpine AS build

WORKDIR /app

# Install Gradle to bootstrap the wrapper jar
RUN apk add --no-cache wget unzip && \
    wget -q https://services.gradle.org/distributions/gradle-9.0.0-bin.zip -O /tmp/gradle.zip && \
    unzip -q /tmp/gradle.zip -d /opt && \
    rm /tmp/gradle.zip
ENV PATH="/opt/gradle-9.0.0/bin:${PATH}"

# Copy build files and download dependencies
COPY build.gradle settings.gradle gradle.properties ./
RUN gradle dependencies --no-daemon || true

# Copy source and build the JAR
COPY src ./src
RUN gradle bootJar --no-daemon

# Runtime stage
FROM eclipse-temurin:21-jre-alpine

WORKDIR /app

COPY --from=build /app/build/libs/business-registry.jar app.jar

EXPOSE 8084

ENTRYPOINT ["java", "-jar", "app.jar"]

