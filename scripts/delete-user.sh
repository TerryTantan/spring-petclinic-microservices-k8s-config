#!/bin/bash
# This script removes a user from the Kubernetes cluster

# Check if a username was provided
if [ $# -eq 0 ]; then
  echo "Error: No username provided." >&2
  exit 1
fi

user=$1
file="./argocd-apps/values.yaml"

# Extract users block
users_block=$(sed -n '/^[[:space:]]*users:/,/^[^[:space:]]/p' "$file")

# Check if user exists
if ! echo "$users_block" | grep -q "^[[:space:]]*-\s*$user\s*$"; then
  echo "Error: User '$user' does not exist." >&2
  exit 1
fi

# Remove the user from the users block
tmp_file=$(mktemp)
awk -v user="$user" '
  BEGIN { skip=0 }
  /^[[:space:]]*users:/ { print; skip=1; next }
  skip && /^[^[:space:]]/ { skip=0 }
  skip && $0 ~ "^[[:space:]]*-[[:space:]]*"user"$" { next }
  { print }
' "$file" > "$tmp_file" && mv "$tmp_file" "$file"

# Remove user's directory
rm -rf "users/$user"

# Commit and push changes
git add .
git commit -m "Removed user $user and cleaned up resources"
git push origin main

# Helm upgrade the ArgoCD applications
helm upgrade argocd-apps ./argocd-apps --namespace argocd
