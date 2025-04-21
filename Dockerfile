# //////////// Build stage ////////////
# FROM eclipse-temurin:11-jre as builder
FROM eclipse-temurin:11-jre-alpine AS builder

WORKDIR /app

# Copy only necessary files
COPY validationtool-1.5.0-standalone.jar scenarios.xml EN16931-CII-validation.xslt EN16931-UBL-validation.xslt /app/
COPY resources /app/resources

# //////////// Final runtime stage ////////////
FROM eclipse-temurin:11-jre-alpine AS runtime

# Create a non-root user for security
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Set working directory
WORKDIR /app

# Copy built app from builder stage
COPY --from=builder /app /app

# Set permissions (just in case)
RUN chown -R appuser:appgroup /app

# Switch to non-root user
USER appuser

# Expose only required port
EXPOSE 8081

# Healthcheck (optional but recommended)
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s CMD wget -qO- http://localhost:8081 || exit 1

# Run the app
CMD ["java", "-jar", "validationtool-1.5.0-standalone.jar", "-s", "scenarios.xml", "-r", "/app", "-D", "-H", "0.0.0.0", "-P", "8081", "--disable-gui"]
