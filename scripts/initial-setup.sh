#!/bin/bash
# This script sets up the initial environment for the K8S cluster.

# Nginx Ingress Controller Setup Script
echo "Setting up Nginx Ingress Controller..."
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm uninstall ingress-nginx --namespace ingress-nginx 
helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace \
  --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-health-probe-request-path"=/healthz \
  --set controller.service.externalTrafficPolicy=Local
echo "Nginx Ingress Controller setup complete."

# Kubeseal Setup Script
echo "Setting up Kubeseal..."
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm uninstall sealed-secrets-controller --namespace kube-system
helm install sealed-secrets-controller bitnami/sealed-secrets \
  --namespace kube-system \
  --create-namespace
echo "Kubeseal setup complete." 

# ArgoCD Setup Script
echo "Setting up ArgoCD..."
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm uninstall argocd --namespace argocd
helm install argocd argo/argo-cd \
  --namespace argocd \
  --create-namespace \
  --set server.service.type=LoadBalancer
echo "ArgoCD setup complete."

# ArgoCD application setup
echo "Setting up ArgoCD applications..."
helm uninstall argocd-apps --namespace argocd 
kubectl delete secret argocd-initial-admin-secret --namespace argocd --ignore-not-found
helm install argocd-apps ./argocd-apps --namespace argocd 
echo "ArgoCD applications setup complete."
echo "Initial credentials for ArgoCD:"
echo "- Username: admin"
echo "- Password: $(kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath='{.data.password}' | base64 --decode)"
