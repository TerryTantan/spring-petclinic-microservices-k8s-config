# spring-petclinic-microservices-k8s-config

This is a repository storing configuration files for K8S cluster using ArgoCD.

## Initial Setup Instruction
Prerequisite: 
- Using a Linux distro.
- Already installed helm and connected to a K8S cluster.

First installation:
```bash
./scripts/initial-setup.sh
```

Deployment:
user-deploy.sh
```bash
chmod u+x ./scripts/user-deploy.sh
./scripts/user-deploy.sh namespace:john config-server:v1.0 api-gateway:v2.0 customers-service:v1.5
```

user-cleanup.sh
```bash
chmod u+x scripts/user-cleanup.sh
./scripts/user-cleanup.sh john
```