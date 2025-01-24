
# helx-lsc

**helx-lsc** is a project designed to containerize the [LSC (LDAP Synchronization Connector)](https://lsc-project.org/) software and make it deployable on Kubernetes via Helm. The LSC software facilitates efficient and robust LDAP synchronization for various environments.

## Features

- **Containerized LSC**: Uses a Dockerfile to package the LSC software for portability and scalability.
- **Helm Chart**: A Helm chart is included for easy deployment and management on Kubernetes clusters.
- **Helper Scripts**: Contains scripts to automate tasks like creating Kubernetes secrets from certificates for LDAPS support.
- **Custom Configuration**: Supports customization via ConfigMaps and Secrets to tailor the LSC deployment to specific synchronization needs.

## Getting Started

### Prerequisites

- A Kubernetes cluster (v1.21+ recommended)
- Helm (v3.0+)
- Docker (for building the container image)

### Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/your-repo/helx-lsc.git
   cd helx-lsc
   ```

2. Build the Docker image:
   ```bash
   docker build -t helx-lsc:latest -f Dockerfile .
   ```

3. Deploy the Helm chart:
   ```bash
   helm install helx-lsc ./helm-chart
   ```

4. Customize the configuration:
   - Modify the `values.yaml` in the Helm chart to specify your LDAP endpoints, credentials, and synchronization settings.
   - Use helper scripts from the `scripts/` directory as needed, such as generating Secrets for LDAPS.

### File Overview

- **`Dockerfile`**: Defines the containerization of the LSC software.
- **`deployment.yaml`**: Kubernetes Deployment for running the LSC container.
- **`configmap.yaml`**: Kubernetes ConfigMap for passing configuration to the LSC container.
- **`_config.tpl`**: Helm template for generating Kubernetes manifests.
- **`entrypoint.sh`**: Startup script for initializing the container.
- **`scripts/`**: Helper scripts for managing secrets and other auxiliary tasks.

### Example: Creating a Secret for LDAPS

Run the following script to create a Kubernetes Secret from a certificate file:
```bash
./scripts/create-ldaps-secret.sh /path/to/cert.pem
```

This will generate a Secret that can be referenced in your Helm chart values.

## Usage

Once deployed, LSC will synchronize LDAP directories based on the configurations provided. Logs can be accessed via:
```bash
kubectl logs -l app=helx-lsc
```

## Contributing

Contributions are welcome! Please open an issue or submit a pull request if you'd like to contribute.

## License

[MIT License](LICENSE)

## Acknowledgments

- [LSC Project](https://lsc-project.org/)
- [GitHub Repository for LSC](https://github.com/lsc-project/lsc)
