#!/bin/bash
# This script sets up the initial environment for the K8S cluster.

# Nginx Ingress Controller Setup Script
echo "Setting up Nginx Ingress Controller..."
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace
echo "Nginx Ingress Controller setup complete."

# ArgoCD Setup Script
echo "Setting up ArgoCD..."
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm install argocd argo/argo-cd \
  --namespace argocd \
  --create-namespace \
  --set server.service.type=LoadBalancer
echo "ArgoCD setup complete."

# ArgoCD application setup
echo "Setting up ArgoCD applications..."
helm uninstall argocd-apps --namespace argocd 
helm install argocd-apps ./argocd-apps --namespace argocd 
echo "ArgoCD applications setup complete."
echo "Initial credentials for ArgoCD:"
echo "- Username: admin"
echo "- Password: $(kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath='{.data.password}' | base64 --decode)"
