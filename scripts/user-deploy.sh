#!/bin/bash

# Check if at least namespace is provided
if [ "$#" -lt 1 ]; then
    echo "Usage: $0 namespace:{user_name}"
    echo "Note: "
    echo "  - staging environment uses staging images from values-staging.yaml"
    echo "  - all other users use dev images from values-dev.yaml"
    exit 1
fi

# Initialize variables with default values
namespace=""
ingress_prefix="users"

# Function to extract tags based on environment
get_tags_from_environment() {
    local env_suffix
    local values_file
    
    if [ "$namespace" = "staging" ]; then
        env_suffix="staging"
        values_file="./spring-petclinic/values-staging.yaml"
        echo "Using staging environment images and tags"
    else
        env_suffix="dev"
        values_file="./spring-petclinic/values-dev.yaml"
        echo "Using dev environment images and tags"
    fi
    
    if [ -f "$values_file" ]; then
        # Extract tags from the tags: section only, not from image.names section
        config_server_tag=$(sed -n '/^tags:/,/^[a-zA-Z]/p' "$values_file" | grep "config-server-${env_suffix}:" | sed 's/.*: *"\?\([^"]*\)"\?.*/\1/')
        discovery_server_tag=$(sed -n '/^tags:/,/^[a-zA-Z]/p' "$values_file" | grep "discovery-server-${env_suffix}:" | sed 's/.*: *"\?\([^"]*\)"\?.*/\1/')
        admin_server_tag=$(sed -n '/^tags:/,/^[a-zA-Z]/p' "$values_file" | grep "admin-server-${env_suffix}:" | sed 's/.*: *"\?\([^"]*\)"\?.*/\1/')
        api_gateway_tag=$(sed -n '/^tags:/,/^[a-zA-Z]/p' "$values_file" | grep "api-gateway-${env_suffix}:" | sed 's/.*: *"\?\([^"]*\)"\?.*/\1/')
        customers_service_tag=$(sed -n '/^tags:/,/^[a-zA-Z]/p' "$values_file" | grep "customers-service-${env_suffix}:" | sed 's/.*: *"\?\([^"]*\)"\?.*/\1/')
        genai_service_tag=$(sed -n '/^tags:/,/^[a-zA-Z]/p' "$values_file" | grep "genai-service-${env_suffix}:" | sed 's/.*: *"\?\([^"]*\)"\?.*/\1/')
        vets_service_tag=$(sed -n '/^tags:/,/^[a-zA-Z]/p' "$values_file" | grep "vets-service-${env_suffix}:" | sed 's/.*: *"\?\([^"]*\)"\?.*/\1/')
        visits_service_tag=$(sed -n '/^tags:/,/^[a-zA-Z]/p' "$values_file" | grep "visits-service-${env_suffix}:" | sed 's/.*: *"\?\([^"]*\)"\?.*/\1/')
        
        # Set environment suffix for image names
        image_env_suffix="$env_suffix"
        
        echo "Using tags from values-${env_suffix}.yaml:"
        echo "- config-server-${env_suffix}: $config_server_tag"
        echo "- discovery-server-${env_suffix}: $discovery_server_tag"
        echo "- admin-server-${env_suffix}: $admin_server_tag"
        echo "- api-gateway-${env_suffix}: $api_gateway_tag"
        echo "- customers-service-${env_suffix}: $customers_service_tag"
        echo "- genai-service-${env_suffix}: $genai_service_tag"
        echo "- vets-service-${env_suffix}: $vets_service_tag"
        echo "- visits-service-${env_suffix}: $visits_service_tag"
    else
        # Fallback to latest if values file not found
        config_server_tag="latest"
        discovery_server_tag="latest"
        admin_server_tag="latest"
        api_gateway_tag="latest"
        customers_service_tag="latest"
        genai_service_tag="latest"
        vets_service_tag="latest"
        visits_service_tag="latest"
        image_env_suffix="dev"
        echo "Warning: values-${env_suffix}.yaml not found, using 'latest' tags and dev images"
    fi
    
    # Validate tags are not empty
    if [ -z "$config_server_tag" ]; then config_server_tag="latest"; fi
    if [ -z "$discovery_server_tag" ]; then discovery_server_tag="latest"; fi
    if [ -z "$admin_server_tag" ]; then admin_server_tag="latest"; fi
    if [ -z "$api_gateway_tag" ]; then api_gateway_tag="latest"; fi
    if [ -z "$customers_service_tag" ]; then customers_service_tag="latest"; fi
    if [ -z "$genai_service_tag" ]; then genai_service_tag="latest"; fi
    if [ -z "$vets_service_tag" ]; then vets_service_tag="latest"; fi
    if [ -z "$visits_service_tag" ]; then visits_service_tag="latest"; fi
}

# Parse arguments - only namespace is required now
for arg in "$@"; do
    key=$(echo $arg | cut -d':' -f1)
    value=$(echo $arg | cut -d':' -f2)
    
    case $key in
        "namespace")
            namespace=$value
            ;;
        *)
            echo "Note: Only namespace parameter is used. Tags will be pulled from dev environment."
            ;;
    esac
done

# Check if namespace was provided
if [ -z "$namespace" ]; then
    echo "Error: namespace:{user_name} parameter is required"
    echo "Usage: $0 namespace:{user_name}"
    echo "Note: "
    echo "  - staging environment uses staging images from values-staging.yaml"
    echo "  - all other users use dev images from values-dev.yaml"
    exit 1
fi

# Get tags from appropriate environment
get_tags_from_environment

# Create values file content - using environment-specific images and tags
values_content="namespace: $namespace
image:
  repository: terrytantan
  names:
    config-server-$image_env_suffix: terrytantan/spring-petclinic-config-server-$image_env_suffix
    discovery-server-$image_env_suffix: terrytantan/spring-petclinic-discovery-server-$image_env_suffix
    admin-server-$image_env_suffix: terrytantan/spring-petclinic-admin-server-$image_env_suffix
    api-gateway-$image_env_suffix: terrytantan/spring-petclinic-api-gateway-$image_env_suffix
    customers-service-$image_env_suffix: terrytantan/spring-petclinic-customers-service-$image_env_suffix
    genai-service-$image_env_suffix: terrytantan/spring-petclinic-genai-service-$image_env_suffix
    vets-service-$image_env_suffix: terrytantan/spring-petclinic-vets-service-$image_env_suffix
    visits-service-$image_env_suffix: terrytantan/spring-petclinic-visits-service-$image_env_suffix
tags:
  config-server-$image_env_suffix: \"$config_server_tag\"
  discovery-server-$image_env_suffix: \"$discovery_server_tag\"
  admin-server-$image_env_suffix: \"$admin_server_tag\"
  api-gateway-$image_env_suffix: \"$api_gateway_tag\"
  customers-service-$image_env_suffix: \"$customers_service_tag\"
  genai-service-$image_env_suffix: \"$genai_service_tag\"
  vets-service-$image_env_suffix: \"$vets_service_tag\"
  visits-service-$image_env_suffix: \"$visits_service_tag\"
lokiNamespace: $namespace
ingressPrefix: $ingress_prefix"

# Handle based on namespace
if [ "$namespace" = "dev" ] || [ "$namespace" = "staging" ]; then
    # For dev and staging, only create values file in spring-petclinic directory
    echo "Creating values file with content:"
    echo "---"
    echo "$values_content"
    echo "---"
    echo "$values_content" > "./spring-petclinic/values-$namespace.yaml"
    echo "Created values-$namespace.yaml in spring-petclinic directory"
    
    # Validate YAML syntax
    if command -v python3 >/dev/null 2>&1; then
        python3 -c "import yaml; yaml.safe_load(open('./spring-petclinic/values-$namespace.yaml'))" 2>/dev/null && echo "YAML syntax is valid" || echo "WARNING: YAML syntax validation failed"
    fi
    
    # Create commit message with service tags for dev/staging
    commit_msg="Update values-$namespace.yaml with $image_env_suffix tags:
- config-server-$image_env_suffix: $config_server_tag
- discovery-server-$image_env_suffix: $discovery_server_tag
- admin-server-$image_env_suffix: $admin_server_tag
- api-gateway-$image_env_suffix: $api_gateway_tag
- customers-service-$image_env_suffix: $customers_service_tag
- genai-service-$image_env_suffix: $genai_service_tag
- vets-service-$image_env_suffix: $vets_service_tag
- visits-service-$image_env_suffix: $visits_service_tag"
else
    # For other users, create full directory structure
    user_dir="users/$namespace"
    mkdir -p "$user_dir"
    
    # Create values-{user_name}.yaml
    echo "Creating values file with content:"
    echo "---"
    echo "$values_content"
    echo "---"
    echo "$values_content" > "$user_dir/values-$namespace.yaml"
    
    # Validate YAML syntax
    if command -v python3 >/dev/null 2>&1; then
        python3 -c "import yaml; yaml.safe_load(open('$user_dir/values-$namespace.yaml'))" 2>/dev/null && echo "YAML syntax is valid" || echo "WARNING: YAML syntax validation failed"
    fi
    
    # Copy templates, Chart.yaml, and values.yaml
    cp -r spring-petclinic/templates "$user_dir/"
    cp spring-petclinic/Chart.yaml "$user_dir/"
    cp spring-petclinic/values.yaml "$user_dir/"
    
    echo "Deployment files created successfully in $user_dir"
    
    # Create commit message for new user setup
    commit_msg="Setup deployment for user $namespace using $image_env_suffix images with tags:
- config-server-$image_env_suffix: $config_server_tag
- discovery-server-$image_env_suffix: $discovery_server_tag
- admin-server-$image_env_suffix: $admin_server_tag
- api-gateway-$image_env_suffix: $api_gateway_tag
- customers-service-$image_env_suffix: $customers_service_tag
- genai-service-$image_env_suffix: $genai_service_tag
- vets-service-$image_env_suffix: $vets_service_tag
- visits-service-$image_env_suffix: $visits_service_tag"
fi

# Add changes to git
git add .

# Commit with detailed message
echo -e "$commit_msg" | git commit -F -

# Push changes
git push origin main

echo "Changes have been committed and pushed to repository"
