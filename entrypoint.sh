#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Directory containing the CA certificates
CERT_DIR="/usr/local/lsc/certs"

# Function to import certificates
import_certificates() {
    if [ -d "$CERT_DIR" ]; then
        for cert in "$CERT_DIR"/*.pem; do
            if [ -f "$cert" ]; then
                # Extract filename without directory and extension for alias
                filename=$(basename "$cert")
                alias="${filename%.*}"
                echo "Importing certificate '$cert' with alias '$alias' into truststore..."
                keytool -importcert \
                    -noprompt \
                    -trustcacerts \
                    -alias "$alias" \
                    -file "$cert" \
                    -keystore $JAVA_HOME/lib/security/cacerts \
                    -storepass changeit
            fi
        done
    else
        echo "Warning: Certificate directory '$CERT_DIR' does not exist. Skipping certificate import."
    fi
}

# Ensure two task names are provided
if [ "$#" -ne 2 ]; then
    echo "Error: Incorrect number of arguments provided."
    echo "Usage: $0 <asyncTaskName> <syncTaskName>"
    exit 1
fi

# Import certificates
import_certificates

echo "Starting synchronous task: $1"
/usr/local/lsc/bin/lsc -f /usr/local/lsc/etc -s $1 
echo "Synchronous task $1 completed."

echo "Starting asynchronous task: $2"
exec /usr/local/lsc/bin/lsc -f /usr/local/lsc/etc -a $2
