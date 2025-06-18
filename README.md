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

User management: 
add-user.sh
```bash
chmod u+x ./scripts/add-user.sh
./scripts/add-user.sh john
```

delete-user.sh
```bash
chmod u+x ./scripts/delete-user.sh
./scripts/delete-user.sh john
```

User deployment:
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