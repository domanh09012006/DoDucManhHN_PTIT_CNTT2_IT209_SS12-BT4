# Stage 1: Build the application with Gradle
FROM eclipse-temurin:17-jdk-jammy AS builder
WORKDIR /workspace

# Copy Gradle wrapper and project configuration
COPY gradlew .
COPY gradle gradle
COPY build.gradle settings.gradle ./

# Fix potential Windows CRLF issues and grant execution permissions
RUN sed -i 's/\r$//' gradlew && chmod +x gradlew

# Copy source code and build executable jar
COPY src src
RUN ./gradlew bootJar -x test --no-daemon

# Stage 2: Minimal runtime image
FROM eclipse-temurin:17-jre-jammy
WORKDIR /app

# Copy executable jar from builder stage
COPY --from=builder /workspace/build/libs/*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
