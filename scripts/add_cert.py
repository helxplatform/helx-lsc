#!/usr/bin/env python3

import argparse
import os
import base64
import sys
from kubernetes import client, config
from kubernetes.client.rest import ApiException

def parse_arguments():
    parser = argparse.ArgumentParser(
        description="Manage Kubernetes Secret for CA Certificates."
    )
    parser.add_argument(
        "cert_files",
        metavar="CERT_FILE",
        type=str,
        nargs="+",
        help="Path(s) to the CA certificate file(s) in PEM format."
    )
    parser.add_argument(
        "-n",
        "--namespace",
        type=str,
        default=None,  # Set default to None to detect from context
        help="Kubernetes namespace where the Secret is located. If not specified, uses the current context's default namespace."
    )
    parser.add_argument(
        "--force",
        action="store_true",
        help="Force update the certificate in the Secret if it already exists."
    )
    return parser.parse_args()

def load_kube_config():
    try:
        config.load_kube_config()
    except config.ConfigException:
        try:
            config.load_incluster_config()
        except config.ConfigException:
            print("Error: Could not configure Kubernetes client. Ensure kubeconfig is set or running inside a cluster.")
            sys.exit(1)

def get_current_namespace():
    """
    Retrieves the default namespace from the current Kubernetes context.
    Falls back to 'default' if not set.
    """
    try:
        contexts, active_context = config.list_kube_config_contexts()
        if active_context is None:
            print("Warning: No active Kubernetes context found. Using 'default' namespace.")
            return "default"
        namespace = active_context.get('context', {}).get('namespace', 'default')
        return namespace
    except Exception as e:
        print(f"Error: Unable to retrieve current namespace from context: {e}")
        sys.exit(1)

def read_certificate(cert_path):
    if not os.path.isfile(cert_path):
        print(f"Error: Certificate file '{cert_path}' does not exist.")
        sys.exit(1)
    try:
        with open(cert_path, "rb") as cert_file:
            cert_data = cert_file.read()
        return cert_data
    except Exception as e:
        print(f"Error: Failed to read certificate file '{cert_path}': {e}")
        sys.exit(1)

def get_secret(api_instance, secret_name, namespace):
    try:
        secret = api_instance.read_namespaced_secret(name=secret_name, namespace=namespace)
        return secret
    except ApiException as e:
        if e.status == 404:
            return None
        else:
            print(f"Error: Failed to read Secret '{secret_name}' in namespace '{namespace}': {e}")
            sys.exit(1)

def create_secret(api_instance, secret_name, namespace, data_dict):
    secret_body = client.V1Secret(
        metadata=client.V1ObjectMeta(name=secret_name),
        type="Opaque",
        data=data_dict
    )
    try:
        api_instance.create_namespaced_secret(namespace=namespace, body=secret_body)
        print(f"Secret '{secret_name}' created in namespace '{namespace}'.")
    except ApiException as e:
        print(f"Error: Failed to create Secret '{secret_name}' in namespace '{namespace}': {e}")
        sys.exit(1)

def patch_secret(api_instance, secret_name, namespace, data_dict):
    patch = {
        "data": data_dict
    }
    try:
        api_instance.patch_namespaced_secret(name=secret_name, namespace=namespace, body=patch)
        print(f"Secret '{secret_name}' patched in namespace '{namespace}'.")
    except ApiException as e:
        print(f"Error: Failed to patch Secret '{secret_name}' in namespace '{namespace}': {e}")
        sys.exit(1)

def main():
    args = parse_arguments()
    cert_files = args.cert_files
    namespace = args.namespace
    force_update = args.force

    secret_name = "lsc-ca-certs"

    load_kube_config()

    v1 = client.CoreV1Api()

    # Determine the namespace
    if not namespace:
        namespace = get_current_namespace()
        print(f"No namespace specified. Using namespace from current context: '{namespace}'.")
    else:
        print(f"Using specified namespace: '{namespace}'.")

    # Read and encode all certificates
    certs_to_add = {}
    for cert_path in cert_files:
        cert_data = read_certificate(cert_path)
        encoded_cert = base64.b64encode(cert_data).decode('utf-8')
        filename = os.path.basename(cert_path)
        certs_to_add[filename] = encoded_cert

    # Retrieve existing Secret
    secret = get_secret(v1, secret_name, namespace)

    if not secret:
        # Secret does not exist, create it with all certs
        print(f"Secret '{secret_name}' does not exist in namespace '{namespace}'. Creating it with provided certificate(s).")
        create_secret(v1, secret_name, namespace, certs_to_add)
    else:
        # Secret exists, check each cert
        existing_data = secret.data if secret.data else {}
        new_data = {}
        for key, value in certs_to_add.items():
            if key in existing_data:
                if force_update:
                    print(f"Certificate key '{key}' already exists in Secret '{secret_name}'. Updating it due to --force flag.")
                    new_data[key] = value
                else:
                    print(f"Certificate key '{key}' already exists in Secret '{secret_name}'. Skipping (use --force to overwrite).")
            else:
                print(f"Adding new certificate key '{key}' to Secret '{secret_name}'.")
                new_data[key] = value
        if new_data:
            patch_secret(v1, secret_name, namespace, new_data)
        else:
            print("No changes to apply to the Secret.")

if __name__ == "__main__":
    main()
