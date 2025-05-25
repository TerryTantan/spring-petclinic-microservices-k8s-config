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
ingress_prefix=""

# Parse arguments
for arg in "$@"; do
    key=$(echo $arg | cut -d':' -f1)
    value=$(echo $arg | cut -d':' -f2)
    
    case $key in
        "namespace")
            namespace=$value
            ingress_prefix=$value
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

# Create values file content
values_content="namespace: $namespace
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
ingressPrefix: $ingress_prefix"

# Handle based on namespace
if [ "$namespace" = "dev" ] || [ "$namespace" = "staging" ]; then
    # For dev and staging, only create values file in spring-petclinic directory
    echo "$values_content" > "./spring-petclinic/values-$namespace.yaml"
    echo "Created values-$namespace.yaml in spring-petclinic directory"
    
    # Create commit message with service tags for dev/staging
    commit_msg="Update values-$namespace.yaml with tags:"
    for arg in "$@"; do
        key=$(echo $arg | cut -d':' -f1)
        value=$(echo $arg | cut -d':' -f2)
        if [ "$key" != "namespace" ]; then
            commit_msg="$commit_msg\n- $key: $value"
        fi
    done
else
    # For other users, create full directory structure
    user_dir="users/$namespace"
    mkdir -p "$user_dir"
    
    # Create values-{user_name}.yaml
    echo "$values_content" > "$user_dir/values-$namespace.yaml"
    
    # Copy templates, Chart.yaml, and values.yaml
    cp -r spring-petclinic/templates "$user_dir/"
    cp spring-petclinic/Chart.yaml "$user_dir/"
    cp spring-petclinic/values.yaml "$user_dir/"
    
    echo "Deployment files created successfully in $user_dir"
    
    # Create commit message for new user setup
    commit_msg="Setup deployment for user $namespace with tags:"
    for arg in "$@"; do
        key=$(echo $arg | cut -d':' -f1)
        value=$(echo $arg | cut -d':' -f2)
        if [ "$key" != "namespace" ]; then
            commit_msg="$commit_msg\n- $key: $value"
        fi
    done
fi

# Add changes to git
git add .

# Commit with detailed message
echo -e "$commit_msg" | git commit -F -

# Push changes
git push origin main

echo "Changes have been committed and pushed to repository"
