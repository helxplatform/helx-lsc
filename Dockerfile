# Use an official OpenJDK runtime as a parent image
FROM openjdk:8-jre-slim

# Set environment variables
ENV LSC_VERSION=2.1.6
ENV LSC_HOME=/usr/local/lsc

# Install necessary packages
RUN apt-get update && apt-get install -y wget procps && rm -rf /var/lib/apt/lists/*

# Download and extract LSC
RUN wget https://lsc-project.org/archives/lsc-core-${LSC_VERSION}-dist.tar.gz -O /tmp/lsc.tar.gz \
    && mkdir -p ${LSC_HOME} \
    && tar -xzf /tmp/lsc.tar.gz -C ${LSC_HOME} --strip-components=1 \
    && rm /tmp/lsc.tar.gz

# Copy configuration files
COPY lsc.xml ${LSC_HOME}/etc/lsc.xml
COPY xsd/ ${LSC_HOME}/xsd/

# Copy the entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Expose any necessary ports (if applicable)
# EXPOSE 8080

# Set the working directory
WORKDIR ${LSC_HOME}

# Define the entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Define the command
CMD ["none"]
