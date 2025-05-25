#!/bin/bash
# This script cleans up user directory while preserving specific files

# Check if a username was provided
if [ $# -eq 0 ]; then
  echo "Error: No username provided." >&2
  exit 1
fi

user=$1
user_dir="users/$user"

# Check if user directory exists
if [ ! -d "$user_dir" ]; then
    echo "Error: User directory $user_dir does not exist" >&2
    exit 1
fi

# Check if Chart.yaml exists
if [ ! -f "$user_dir/Chart.yaml" ]; then
    echo "Error: Chart.yaml not found in $user_dir" >&2
    exit 1
fi

# Create a temporary directory with descriptive name
temp_dir="/tmp/delete-user-${user}-$(date +%s)"
mkdir -p "$temp_dir"

# Move files to preserve to temp directory
mv "$user_dir/Chart.yaml" "$temp_dir/"

# Remove all files in user directory
rm -rf "$user_dir"/*

# Restore Chart.yaml
mv "$temp_dir/Chart.yaml" "$user_dir/"

# Create empty values files
touch "$user_dir/values.yaml"
touch "$user_dir/values-$user.yaml"

# Remove temporary directory
rm -rf "$temp_dir"

# Commit changes
git add .
git commit -m "Cleaned up resources for user $user (preserved Chart.yaml and empty values files)"
git push origin main

echo "Successfully cleaned up directory for user $user and preserved required files in $user_dir"
