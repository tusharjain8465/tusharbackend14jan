# ==============================
# Step 1: Build the application
# ==============================
FROM eclipse-temurin:17-jdk-jammy AS builder

WORKDIR /app

# Copy Maven wrapper and config files
COPY pom.xml .
COPY mvnw .
COPY .mvn .mvn

# Give execute permission to mvnw (important for Linux/Render)
RUN chmod +x mvnw

# Download dependencies (this layer gets cached)
RUN ./mvnw dependency:go-offline

# Copy source code
COPY src ./src

# Build the Spring Boot JAR
RUN ./mvnw clean package -DskipTests


# ==============================
# Step 2: Run the application
# ==============================
FROM eclipse-temurin:17-jre-jammy

WORKDIR /app

# Copy built jar from builder stage
COPY --from=builder /app/target/*.jar app.jar

# Render uses PORT env variable
ENV PORT=8080

EXPOSE 8080

# Run application
ENTRYPOINT ["java", "-jar", "app.jar"]
