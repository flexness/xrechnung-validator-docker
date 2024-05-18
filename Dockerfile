# Use a smaller base image for building
FROM adoptopenjdk:11-jre-hotspot AS builder

# Set the working directory
WORKDIR /app

# Copy only necessary application files
COPY validationtool-1.5.0-standalone.jar scenarios.xml EN16931-CII-validation.xslt EN16931-UBL-validation.xslt /app/
COPY resources /app/resources

# Use a minimal base image for the final image
FROM alpine:3.14

# Install OpenJDK 11 JRE
RUN apk --no-cache add openjdk11-jre

# Set the working directory
WORKDIR /app

# Copy files from the builder stage
COPY --from=builder /app /app

# Remove unnecessary files and dependencies
# RUN rm -rf /app/resources

# Expose port 8081
EXPOSE 8081

# Set JVM options for memory optimization
ENV JAVA_OPTS="-Xms64m -Xmx256m"

# Set the default command to run the Java application
CMD ["java", "-jar", "validationtool-1.5.0-standalone.jar", "-s", "scenarios.xml", "-r", "/app", "-D", "-H", "0.0.0.0", "-P", "8081"]
