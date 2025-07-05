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
./scripts/user-deploy.sh namespace:john
```
Note: 
- Users (except staging) will use dev images with tags from values-dev.yaml
- Staging environment will use staging images with tags from values-staging.yaml

user-cleanup.sh
```bash
chmod u+x scripts/user-cleanup.sh
./scripts/user-cleanup.sh john
```