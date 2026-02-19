FROM gradle:8.5-jdk21-alpine AS build

ENTRYPOINT ["java", "-jar", "app.jar"]
EXPOSE 8083
COPY --from=build /app/build/libs/business-registry.jar app.jar
WORKDIR /app
FROM eclipse-temurin:21-jre-alpine

RUN gradle bootJar --no-daemon
COPY src ./src
COPY build.gradle settings.gradle gradle.properties ./
WORKDIR /app
