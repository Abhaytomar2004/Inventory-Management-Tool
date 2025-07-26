# Build stage - Using valid Maven+Java 21 image
FROM maven:3.9.6-eclipse-temurin-21-alpine AS builder
WORKDIR /app

# Copy POM first for dependency caching
COPY pom.xml .
# Download dependencies (offline mode)
RUN mvn dependency:go-offline

# Copy source code
COPY src ./src
# Build the application
RUN mvn clean package -DskipTests

# Runtime stage - Using matching Java 21 JRE
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app

# Copy built JAR from builder
COPY --from=builder /app/target/*.jar app.jar

EXPOSE 8082

ENTRYPOINT ["java", "-jar", "app.jar"]