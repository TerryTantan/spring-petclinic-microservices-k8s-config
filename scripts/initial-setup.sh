#!/bin/bash
# This script sets up the initial environment for the K8S cluster.

# Nginx Ingress Controller Setup
echo "Setting up Nginx Ingress Controller..."
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm uninstall ingress-nginx --namespace ingress-nginx || true
helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace \
  --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-health-probe-request-path"=/healthz \
  --set controller.service.externalTrafficPolicy=Local
echo "Nginx Ingress Controller setup complete."

# Kubeseal Setup
echo "Setting up Kubeseal..."
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm uninstall sealed-secrets-controller --namespace kube-system || true
helm install sealed-secrets-controller bitnami/sealed-secrets \
  --namespace kube-system \
  --create-namespace
echo "Kubeseal setup complete."

# ArgoCD Setup
echo "Setting up ArgoCD..."
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

helm uninstall argocd --namespace argocd || true
helm install argocd argo/argo-cd \
  --namespace argocd \
  --create-namespace \
  --set server.service.type=LoadBalancer \
  -f ./scripts/argocd/values.yaml \
  --wait \
  --timeout 300s
echo "ArgoCD setup complete."

echo "Initial credentials for ArgoCD:"
echo "- Username: admin"
CURRENT_ADMIN_PASSWORD=$(kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath='{.data.password}' | base64 --decode)
echo "- Password: $CURRENT_ADMIN_PASSWORD"

# ArgoCD Application Setup
echo "Setting up ArgoCD applications..."
helm uninstall argocd-apps --namespace argocd || true
helm install argocd-apps ./argocd-apps \
  --namespace argocd \
  --create-namespace

echo "ArgoCD applications setup complete."

# ArgoCD Image Updater Setup
echo "Setting up ArgoCD Image Updater..."
argocd account update-password \
  --account image-updater \
  --new-password 123456789 \
  --current-password $CURRENT_ADMIN_PASSWORD \
  --server "$ARGOCD_IP" \
  --insecure  

ARGOCD_IP=$(kubectl -n argocd get svc argocd-server -o jsonpath="{.status.loadBalancer.ingress[0].ip}")
argocd login "$ARGOCD_IP" \
  --username image-updater \
  --password 123456789 \
  --insecure

TOKEN=$(argocd account generate-token --account image-updater)
helm uninstall argocd-image-updater --namespace argocd-image-updater || true
helm install argocd-image-updater argo/argocd-image-updater \
  --namespace argocd-image-updater \
  --create-namespace \
  --set config.argocd.serverAddress="$ARGOCD_IP" \
  --set config.argocd.token="$TOKEN"
echo "ArgoCD Image Updater setup complete."
