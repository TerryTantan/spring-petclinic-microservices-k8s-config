#!/bin/bash
# This script adds a new user to the Kubernetes cluster 

# Check if there are any arguments provided
if [ $# -eq 0 ]; then
  echo "Error: No arguments provided." >&2
  exit 1
fi

# Check if the user exists
user=$1
file="./argocd-apps/values.yaml"
namespaces_block=$(sed -n '/^[[:space:]]*users:/,/^[^[:space:]]/p' "$file" | tail -n +2)

if echo "$namespaces_block" | grep -q "^[[:space:]]*-\s*$user\s*$"; then
  echo "Error: User '$user' already exists." >&2
  exit 1
fi

# Add the user to the ArgoCD applications
echo >> ./argocd-apps/values.yaml
echo -n "  -" $user >> ./argocd-apps/values.yaml

# Make a folder
mkdir -p ${user}/templates
cp ./spring-petclinic/Chart.yaml ${user}/Chart.yaml
touch ${user}/values.yaml

# Helm upgrade the ArgoCD applications
helm upgrade argocd-apps ./argocd-apps --namespace argocd