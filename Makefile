# Makefile for building and pushing the LSC Docker image

# Variables (customize these according to your needs)
CONTAINER_REPO ?= containers.renci.org/helxplatform
#CONTAINER_REPO ?= docker.io/wateim
IMAGE_NAME ?= lsc
IMAGE_TAG ?= v2.1.6

# Full image name
IMAGE_FULL_NAME = $(CONTAINER_REPO)/$(IMAGE_NAME):$(IMAGE_TAG)

.PHONY: all build push clean help

# Default target
all: help

# Build the Docker image
build:
	docker build --platform=linux/amd64 -t $(IMAGE_FULL_NAME) .

# Push the Docker image to the repository
push: build
	docker push $(IMAGE_FULL_NAME)

# Remove the local Docker image
clean:
	docker rmi $(IMAGE_FULL_NAME)

# Display help
help:
	@echo "Makefile Commands:"
	@echo "  make build      - Build the Docker image"
	@echo "  make push       - Push the Docker image to the repository"
	@echo "  make clean      - Remove the local Docker image"
	@echo "  make help       - Display this help message"
