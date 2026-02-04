# --- Stage 1: Build (JDK 21) ---
FROM gradle:9.0.0-jdk21 AS builder

WORKDIR /home/gradle/src

# Copy build config first to cache dependencies
COPY build.gradle.kts settings.gradle.kts ./

# Copy source code
COPY src ./src

# Build the JAR (skipping tests for speed)
RUN gradle bootJar -x test --no-daemon

# --- Stage 2: Run (JRE 21) ---
FROM eclipse-temurin:21-jre-alpine

WORKDIR /app

# Copy the built JAR from the builder stage
COPY --from=builder /home/gradle/src/build/libs/*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
