# Build stage - Using valid Maven+Java 21 image
FROM maven:3.9.6-eclipse-temurin-21-alpine AS builder
WORKDIR /app


COPY pom.xml .

RUN mvn dependency:go-offline


COPY src ./src

RUN mvn clean package -DskipTests


FROM eclipse-temurin:21-jre-alpine
WORKDIR /app


COPY --from=builder /app/target/*.jar app.jar

EXPOSE 8082

ENTRYPOINT ["java", "-jar", "app.jar"]