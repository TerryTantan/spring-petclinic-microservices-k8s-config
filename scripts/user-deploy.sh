#!/bin/bash

# Check if at least namespace is provided
if [ "$#" -lt 1 ]; then
    echo "Usage: $0 namespace:{user_name} [service:{tag_value} ...]"
    exit 1
fi

# Initialize variables with default values
namespace=""
config_server_tag="latest"
discovery_server_tag="latest"
tracing_server_tag="latest"
admin_server_tag="latest"
api_gateway_tag="latest"
customers_service_tag="latest"
genai_service_tag="latest"
vets_service_tag="latest"
visits_service_tag="latest"

# Parse arguments
for arg in "$@"; do
    key=$(echo $arg | cut -d':' -f1)
    value=$(echo $arg | cut -d':' -f2)
    
    case $key in
        "namespace")
            namespace=$value
            ;;
        "config-server")
            config_server_tag=$value
            ;;
        "discovery-server")
            discovery_server_tag=$value
            ;;
        "tracing-server")
            tracing_server_tag=$value
            ;;
        "admin-server")
            admin_server_tag=$value
            ;;
        "api-gateway")
            api_gateway_tag=$value
            ;;
        "customers-service")
            customers_service_tag=$value
            ;;
        "genai-service")
            genai_service_tag=$value
            ;;
        "vets-service")
            vets_service_tag=$value
            ;;
        "visits-service")
            visits_service_tag=$value
            ;;
        *)
            echo "Unknown parameter: $key"
            ;;
    esac
done

# Check if namespace was provided
if [ -z "$namespace" ]; then
    echo "Error: namespace:{user_name} parameter is required"
    exit 1
fi

# Create user directory if it doesn't exist
user_dir="users/$namespace"
mkdir -p "$user_dir"

# Create values-{user_name}.yaml
cat > "$user_dir/values-$namespace.yaml" << EOF
namespace: $namespace
image:
  repository: terrytantan
tags:
  config-server: $config_server_tag
  discovery-server: $discovery_server_tag
  tracing-server: $tracing_server_tag
  admin-server: $admin_server_tag
  api-gateway: $api_gateway_tag
  customers-service: $customers_service_tag
  genai-service: $genai_service_tag
  vets-service: $vets_service_tag
  visits-service: $visits_service_tag
EOF

# Copy templates, Chart.yaml, and values.yaml
cp -r spring-petclinic/templates "$user_dir/"
cp spring-petclinic/Chart.yaml "$user_dir/"
cp spring-petclinic/values.yaml "$user_dir/"

# Commit
git add .
git commit -m "Added deployment files for user $namespace with specified tags"
git push origin main

echo "Deployment files created successfully in $user_dir"
