## Use multi-stage build
## Stage 1: Build the application
#FROM gradle:7.6-jdk17 AS builder
#
## Set the working directory inside the container
#WORKDIR /app
#
## Copy Gradle files and application source code
#COPY build.gradle.kts settings.gradle.kts /app/
#COPY src /app/src
#COPY gradlew /app/
#COPY gradle /app/gradle
#
## Build the application
#RUN ./gradlew build --no-daemon
#
## Stage 2: Package the application
#FROM amazoncorretto:17
#
## Set the working directory inside the container
#WORKDIR /app
#
## Copy the built jar file from the previous stage
#COPY --from=builder /app/build/libs/*.jar /app/app.jar
#
## Expose the application's default port (change this if necessary)
#EXPOSE 8081
#
## Run the jar file
#ENTRYPOINT ["java", "-jar", "/app/app.jar"]
#


# Use a base image with Java 17 or whatever version you're using
FROM amazoncorretto:17

# Set the working directory inside the container
WORKDIR /app

# Copy the jar file (built from Maven or Gradle) into the container
COPY build/libs/bestbuy-search-ai-0.0.1-SNAPSHOT.jar /app/app.jar

# Expose the application's default port (change this if necessary)
EXPOSE 8081

# Run the jar file
ENTRYPOINT ["java", "-jar", "/app/app.jar"]