# Kubernetes and Ansible Commands Reference

This document contains all the important commands for deploying and managing the Travel Booking System on Kubernetes using Ansible.

## Table of Contents
1. [Prerequisites Setup](#prerequisites-setup)
2. [Ansible Commands](#ansible-commands)
3. [Kubernetes Commands](#kubernetes-commands)
4. [Docker Commands](#docker-commands)
5. [Troubleshooting Commands](#troubleshooting-commands)
6. [Minikube Commands](#minikube-commands)

---

## Prerequisites Setup

### Install Ansible
```bash
sudo apt update
sudo apt install -y ansible

# Verify installation
ansible --version
```

### Install Docker
```bash
sudo apt update && \
sudo apt install -y ca-certificates curl gnupg lsb-release && \
sudo mkdir -p /etc/apt/keyrings && \
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null && \
sudo apt update && \
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin && \
sudo service docker start && \
sudo systemctl enable docker && \
sudo usermod -aG docker $USER && \
newgrp docker

# Verify installation
docker --version
docker ps
```

### Install Minikube
```bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
rm minikube-linux-amd64

# Verify installation
minikube version
```

### Install kubectl
```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl

# Verify installation
kubectl version --client
```

### Start Minikube
```bash
# Start with Docker driver
minikube start --driver=docker --memory=4000 --cpus=2

# Check status
minikube status

# Get cluster info
kubectl cluster-info
```

---

## Ansible Commands

### Basic Ansible Commands

#### Check Ansible Version
```bash
ansible --version
```

#### Test Connectivity
```bash
cd ansible
ansible all -m ping -i inventory/hosts
```

#### Check Playbook Syntax
```bash
cd ansible
ansible-playbook playbooks/deploy-all.yml --syntax-check
```

#### Dry Run (Check Mode)
```bash
cd ansible
ansible-playbook playbooks/deploy-all.yml --check
```

#### List Hosts
```bash
cd ansible
ansible all --list-hosts -i inventory/hosts
```

#### List Tasks
```bash
cd ansible
ansible-playbook playbooks/deploy-all.yml --list-tasks
```

### Deployment Commands

#### Deploy Complete Application
```bash
cd ansible
ansible-playbook playbooks/deploy-all.yml
```

#### Deploy with Verbose Output
```bash
cd ansible
ansible-playbook playbooks/deploy-all.yml -v    # verbose
ansible-playbook playbooks/deploy-all.yml -vv   # more verbose
ansible-playbook playbooks/deploy-all.yml -vvv  # very verbose
```

#### Deploy Individual Components

**Deploy Database Only**
```bash
cd ansible
ansible-playbook playbooks/deploy-database.yml
```

**Deploy Backend Only**
```bash
cd ansible
ansible-playbook playbooks/deploy-backend.yml
```

**Deploy Frontend Only**
```bash
cd ansible
ansible-playbook playbooks/deploy-frontend.yml
```

#### Deploy with Tags
```bash
cd ansible
# Deploy only database
ansible-playbook playbooks/deploy-all.yml --tags database

# Deploy only backend
ansible-playbook playbooks/deploy-all.yml --tags backend

# Deploy only frontend
ansible-playbook playbooks/deploy-all.yml --tags frontend

# Deploy multiple components
ansible-playbook playbooks/deploy-all.yml --tags "database,backend"
```

#### Skip Tags
```bash
cd ansible
# Skip frontend deployment
ansible-playbook playbooks/deploy-all.yml --skip-tags frontend
```

---

## Kubernetes Commands

### Namespace Management

#### Create Namespace
```bash
kubectl create namespace travel-booking
# Or using manifest
kubectl apply -f kubernetes/namespace.yaml
```

#### List Namespaces
```bash
kubectl get namespaces
kubectl get ns
```

#### Delete Namespace (removes all resources)
```bash
kubectl delete namespace travel-booking
```

#### Set Default Namespace
```bash
kubectl config set-context --current --namespace=travel-booking
```

### Resource Deployment

#### Deploy All Resources
```bash
# Deploy namespace
kubectl apply -f kubernetes/namespace.yaml

# Deploy database
kubectl apply -f kubernetes/database/

# Deploy backend
kubectl apply -f kubernetes/backend/

# Deploy frontend
kubectl apply -f kubernetes/frontend/
```

#### Deploy Specific Resource
```bash
kubectl apply -f kubernetes/database/mysql-deployment.yaml
```

#### Delete Resources
```bash
# Delete specific resource
kubectl delete -f kubernetes/database/mysql-deployment.yaml

# Delete all in directory
kubectl delete -f kubernetes/database/

# Delete all in namespace
kubectl delete all --all -n travel-booking
```

### View Resources

#### Get All Resources
```bash
kubectl get all -n travel-booking
```

#### Get Specific Resource Types
```bash
# Pods
kubectl get pods -n travel-booking
kubectl get pods -n travel-booking -o wide
kubectl get pods -n travel-booking --watch

# Deployments
kubectl get deployments -n travel-booking
kubectl get deploy -n travel-booking

# Services
kubectl get services -n travel-booking
kubectl get svc -n travel-booking

# ConfigMaps
kubectl get configmaps -n travel-booking
kubectl get cm -n travel-booking

# Secrets
kubectl get secrets -n travel-booking

# PersistentVolumeClaims
kubectl get pvc -n travel-booking

# Events
kubectl get events -n travel-booking --sort-by='.lastTimestamp'
```

#### Describe Resources
```bash
# Describe pod
kubectl describe pod <pod-name> -n travel-booking

# Describe service
kubectl describe svc backend-service -n travel-booking

# Describe deployment
kubectl describe deployment backend-deployment -n travel-booking
```

### Logs and Debugging

#### View Logs
```bash
# View pod logs
kubectl logs <pod-name> -n travel-booking

# Follow logs
kubectl logs -f <pod-name> -n travel-booking

# Previous logs (from crashed container)
kubectl logs --previous <pod-name> -n travel-booking

# Logs from specific container in pod
kubectl logs <pod-name> -c <container-name> -n travel-booking

# Tail last N lines
kubectl logs --tail=100 <pod-name> -n travel-booking
```

#### Execute Commands in Pod
```bash
# Interactive shell
kubectl exec -it <pod-name> -n travel-booking -- /bin/bash
kubectl exec -it <pod-name> -n travel-booking -- /bin/sh

# Run single command
kubectl exec <pod-name> -n travel-booking -- ls -la
kubectl exec <pod-name> -n travel-booking -- env
```

#### Port Forwarding
```bash
# Forward local port to pod
kubectl port-forward <pod-name> 8080:8080 -n travel-booking

# Forward to service
kubectl port-forward svc/backend-service 8080:8080 -n travel-booking
kubectl port-forward svc/frontend-service 3000:80 -n travel-booking

# Forward and run in background
kubectl port-forward svc/backend-service 8080:8080 -n travel-booking &
```

#### Copy Files
```bash
# Copy from local to pod
kubectl cp /path/to/local/file <pod-name>:/path/in/pod -n travel-booking

# Copy from pod to local
kubectl cp <pod-name>:/path/in/pod /path/to/local/file -n travel-booking
```

### Scaling

#### Scale Deployments
```bash
# Scale to specific replicas
kubectl scale deployment backend-deployment --replicas=3 -n travel-booking
kubectl scale deployment frontend-deployment --replicas=5 -n travel-booking

# Autoscale
kubectl autoscale deployment backend-deployment --min=2 --max=10 --cpu-percent=80 -n travel-booking
```

### Rolling Updates

#### Update Deployment
```bash
# Update image
kubectl set image deployment/backend-deployment backend=new-image:tag -n travel-booking

# Restart deployment
kubectl rollout restart deployment/backend-deployment -n travel-booking
```

#### Rollout Status
```bash
# Check rollout status
kubectl rollout status deployment/backend-deployment -n travel-booking

# View rollout history
kubectl rollout history deployment/backend-deployment -n travel-booking

# Rollback to previous version
kubectl rollout undo deployment/backend-deployment -n travel-booking

# Rollback to specific revision
kubectl rollout undo deployment/backend-deployment --to-revision=2 -n travel-booking
```

### Resource Management

#### Get Resource Usage
```bash
# Node resources
kubectl top nodes

# Pod resources
kubectl top pods -n travel-booking

# Specific pod
kubectl top pod <pod-name> -n travel-booking
```

#### Edit Resources
```bash
# Edit deployment
kubectl edit deployment backend-deployment -n travel-booking

# Edit service
kubectl edit svc backend-service -n travel-booking

# Edit configmap
kubectl edit cm backend-config -n travel-booking
```

#### Label Management
```bash
# Add label
kubectl label pods <pod-name> environment=production -n travel-booking

# Remove label
kubectl label pods <pod-name> environment- -n travel-booking

# Show labels
kubectl get pods --show-labels -n travel-booking

# Filter by label
kubectl get pods -l app=backend -n travel-booking
```

---

## Docker Commands

### Build Images
```bash
# Build backend image
docker build -t travel-booking-backend:latest -f dockerfiles/Dockerfile.backend /path/to/backend/source

# Build frontend image
docker build -t travel-booking-frontend:latest -f dockerfiles/Dockerfile.frontend /path/to/frontend/source
```

### Tag and Push Images
```bash
# Tag image
docker tag travel-booking-backend:latest username/travel-booking-backend:latest

# Push to Docker Hub
docker push username/travel-booking-backend:latest
docker push username/travel-booking-frontend:latest
```

### Manage Images
```bash
# List images
docker images

# Remove image
docker rmi travel-booking-backend:latest

# Clean up unused images
docker image prune -a
```

### Use Build Script
```bash
# Set environment variables
export DOCKER_USERNAME=yourusername
export BACKEND_SOURCE=/path/to/backend
export FRONTEND_SOURCE=/path/to/frontend

# Run build script
./scripts/build-images.sh
```

---

## Troubleshooting Commands

### Pod Issues

#### Check Pod Status
```bash
kubectl get pods -n travel-booking
kubectl describe pod <pod-name> -n travel-booking
```

#### Pod Not Starting
```bash
# Check events
kubectl get events -n travel-booking --sort-by='.lastTimestamp'

# Check logs
kubectl logs <pod-name> -n travel-booking

# Check previous logs if crashed
kubectl logs --previous <pod-name> -n travel-booking

# Describe pod for detailed info
kubectl describe pod <pod-name> -n travel-booking
```

#### Image Pull Issues
```bash
# Check image pull secrets
kubectl get secrets -n travel-booking

# Describe pod to see image pull error
kubectl describe pod <pod-name> -n travel-booking
```

### Service Issues

#### Check Service Endpoints
```bash
kubectl get endpoints -n travel-booking
kubectl describe svc backend-service -n travel-booking
```

#### Test Service Connectivity
```bash
# From within cluster
kubectl run test-pod --rm -i --tty --image=busybox -n travel-booking -- sh
# Then inside pod:
wget -O- http://backend-service:8080
nc -zv backend-service 8080
```

### Database Issues

#### Check MySQL Logs
```bash
kubectl logs -f mysql-deployment-<pod-id> -n travel-booking
```

#### Access MySQL
```bash
# Get MySQL pod name
kubectl get pods -n travel-booking | grep mysql

# Connect to MySQL
kubectl exec -it <mysql-pod-name> -n travel-booking -- mysql -u root -p
# Enter password: rootpassword123

# Or directly
kubectl exec -it <mysql-pod-name> -n travel-booking -- mysql -u traveluser -p travelbooking
```

#### Test Database Connectivity
```bash
# From backend pod
kubectl exec -it <backend-pod-name> -n travel-booking -- nc -zv mysql-service 3306
```

### Resource Issues

#### Check Resource Quotas
```bash
kubectl describe resourcequota -n travel-booking
```

#### Check Node Capacity
```bash
kubectl describe nodes
kubectl top nodes
```

#### Check PVC Status
```bash
kubectl get pvc -n travel-booking
kubectl describe pvc mysql-pvc -n travel-booking
```

---

## Minikube Commands

### Basic Operations
```bash
# Start Minikube
minikube start --driver=docker --memory=4000 --cpus=2

# Stop Minikube
minikube stop

# Delete Minikube cluster
minikube delete

# Check status
minikube status

# Get cluster IP
minikube ip

# SSH into Minikube
minikube ssh
```

### Service Access
```bash
# Get service URL
minikube service frontend-service -n travel-booking --url
minikube service backend-service -n travel-booking --url

# Open service in browser
minikube service frontend-service -n travel-booking
```

### Dashboard
```bash
# Open Kubernetes dashboard
minikube dashboard

# Get dashboard URL
minikube dashboard --url
```

### Addons
```bash
# List addons
minikube addons list

# Enable addon
minikube addons enable metrics-server
minikube addons enable ingress

# Disable addon
minikube addons disable metrics-server
```

### Debugging
```bash
# View logs
minikube logs

# Check Docker environment
minikube docker-env
eval $(minikube docker-env)
```

---

## Quick Reference Scripts

### Quick Deploy
```bash
# Using provided script
./scripts/deploy.sh
```

### Quick Cleanup
```bash
# Using provided script
./scripts/cleanup.sh
```

### Full Deployment Sequence
```bash
# Start Minikube
minikube start --driver=docker --memory=4000 --cpus=2

# Deploy using Ansible
cd ansible
ansible-playbook playbooks/deploy-all.yml

# Check deployment
kubectl get all -n travel-booking

# Access services
minikube service frontend-service -n travel-booking
minikube service backend-service -n travel-booking
```

### Manual Deployment Sequence
```bash
# Start Minikube
minikube start --driver=docker --memory=4000 --cpus=2

# Create namespace
kubectl apply -f kubernetes/namespace.yaml

# Deploy database
kubectl apply -f kubernetes/database/

# Wait for database
kubectl wait --for=condition=ready pod -l app=mysql -n travel-booking --timeout=300s

# Deploy backend
kubectl apply -f kubernetes/backend/

# Deploy frontend
kubectl apply -f kubernetes/frontend/

# Check status
kubectl get all -n travel-booking

# Access services
minikube service frontend-service -n travel-booking --url
minikube service backend-service -n travel-booking --url
```

---

## Environment Variables

### For Build Scripts
```bash
export DOCKER_REGISTRY=docker.io
export DOCKER_USERNAME=yourusername
export IMAGE_TAG=latest
export BACKEND_SOURCE=/path/to/backend
export FRONTEND_SOURCE=/path/to/frontend
```

### For Kubernetes
```bash
export KUBECONFIG=~/.kube/config
export NAMESPACE=travel-booking
```

---

## Common Issues and Solutions

### Issue: Pods in CrashLoopBackOff
```bash
# Check logs
kubectl logs <pod-name> -n travel-booking
kubectl logs --previous <pod-name> -n travel-booking

# Check events
kubectl describe pod <pod-name> -n travel-booking
```

### Issue: Service Not Accessible
```bash
# Check service
kubectl get svc -n travel-booking
kubectl describe svc <service-name> -n travel-booking

# Check endpoints
kubectl get endpoints -n travel-booking

# Test with port-forward
kubectl port-forward svc/<service-name> 8080:8080 -n travel-booking
```

### Issue: Database Connection Failed
```bash
# Check MySQL pod
kubectl logs <mysql-pod> -n travel-booking

# Check MySQL service
kubectl get svc mysql-service -n travel-booking

# Test connectivity from backend pod
kubectl exec -it <backend-pod> -n travel-booking -- nc -zv mysql-service 3306
```

### Issue: Out of Resources
```bash
# Check node resources
kubectl top nodes
kubectl describe nodes

# Check pod resources
kubectl top pods -n travel-booking

# Scale down if needed
kubectl scale deployment backend-deployment --replicas=1 -n travel-booking
```

---

## Useful Aliases

Add these to your `~/.bashrc` or `~/.zshrc`:

```bash
# Kubectl aliases
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgs='kubectl get services'
alias kgd='kubectl get deployments'
alias kga='kubectl get all'
alias kl='kubectl logs'
alias kd='kubectl describe'
alias ke='kubectl exec -it'
alias kpf='kubectl port-forward'

# Namespace specific
alias kgpn='kubectl get pods -n travel-booking'
alias kgsn='kubectl get services -n travel-booking'
alias kgan='kubectl get all -n travel-booking'

# Minikube aliases
alias mk='minikube'
alias mks='minikube start'
alias mkst='minikube stop'
alias mkd='minikube dashboard'
```

After adding, reload your shell:
```bash
source ~/.bashrc  # or source ~/.zshrc
```

---

## Additional Resources

- Kubernetes Documentation: https://kubernetes.io/docs/
- Ansible Documentation: https://docs.ansible.com/
- Docker Documentation: https://docs.docker.com/
- Minikube Documentation: https://minikube.sigs.k8s.io/docs/

---

**Student Information**
- Name: [Your Name]
- ID: 2300031632
- Lab: S-218 Lab In-Exam 2
