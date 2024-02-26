FROM openjdk:11-jre-slim

# Create a directory in the container to store additional files
WORKDIR /app

# Copy the JAR file and additional files into the container
COPY validationtool-1.5.0-standalone.jar /app/validationtool-1.5.0-standalone.jar
COPY scenarios.xml /app/scenarios.xml
COPY resources /app/resources
COPY libs /app/libs
COPY EN16931-CII-validation.xslt /app/EN16931-CII-validation.xslt
COPY EN16931-UBL-validation.xslt /app/EN16931-UBL-validation.xslt

# Expose the port used by the GUI
EXPOSE 8081

# Specify the command to run the JAR file with additional arguments
CMD ["java", "-jar", "validationtool-1.5.0-standalone.jar", "-s", "scenarios.xml", "-r", "/app", "-D", "-H", "0.0.0.0", "-P", "8081"]