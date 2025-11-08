# Travel Booking System - Kubernetes Deployment with Ansible

This repository contains Kubernetes manifests and Ansible playbooks to deploy the Travel Booking System fullstack application on Kubernetes.

## Application Architecture

- **Frontend**: React application (Port 3000)
- **Backend**: Spring Boot application (Port 8080)
- **Database**: MySQL (Port 3306)

## Prerequisites

### 1. Install Ansible
```bash
sudo apt update
sudo apt install -y ansible
```

### 2. Install Docker
```bash
sudo apt update && sudo apt install -y ca-certificates curl gnupg lsb-release && \
sudo mkdir -p /etc/apt/keyrings && \
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null && \
sudo apt update && \
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin && \
sudo service docker start && \
sudo systemctl enable docker && \
sudo usermod -aG docker $USER && \
newgrp docker && \
docker --version
```

### 3. Install Minikube
```bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && \
sudo install minikube-linux-amd64 /usr/local/bin/minikube && \
rm minikube-linux-amd64
```

### 4. Start Minikube
```bash
minikube start --driver=docker --memory=4000 --cpus=2
minikube status
```

### 5. Install kubectl
```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
rm kubectl && \
kubectl version --client
```

## Project Structure

```
.
├── README.md
├── ansible/
│   ├── ansible.cfg
│   ├── inventory/
│   │   └── hosts
│   ├── playbooks/
│   │   ├── deploy-all.yml
│   │   ├── deploy-backend.yml
│   │   ├── deploy-database.yml
│   │   └── deploy-frontend.yml
│   ├── roles/
│   │   ├── backend/
│   │   │   ├── tasks/
│   │   │   │   └── main.yml
│   │   │   ├── templates/
│   │   │   │   └── backend-deployment.yml.j2
│   │   │   └── vars/
│   │   │       └── main.yml
│   │   ├── database/
│   │   │   ├── tasks/
│   │   │   │   └── main.yml
│   │   │   ├── templates/
│   │   │   │   └── database-deployment.yml.j2
│   │   │   └── vars/
│   │   │       └── main.yml
│   │   └── frontend/
│   │       ├── tasks/
│   │       │   └── main.yml
│   │       ├── templates/
│   │       │   └── frontend-deployment.yml.j2
│   │       └── vars/
│   │           └── main.yml
│   └── group_vars/
│       └── all.yml
└── kubernetes/
    ├── backend/
    │   ├── backend-deployment.yaml
    │   ├── backend-service.yaml
    │   └── backend-configmap.yaml
    ├── frontend/
    │   ├── frontend-deployment.yaml
    │   └── frontend-service.yaml
    ├── database/
    │   ├── mysql-deployment.yaml
    │   ├── mysql-service.yaml
    │   ├── mysql-pvc.yaml
    │   └── mysql-secret.yaml
    └── namespace.yaml
```

## Quick Start

### Using Kubernetes Manifests Directly

1. **Create namespace:**
   ```bash
   kubectl apply -f kubernetes/namespace.yaml
   ```

2. **Deploy database:**
   ```bash
   kubectl apply -f kubernetes/database/
   ```

3. **Deploy backend:**
   ```bash
   kubectl apply -f kubernetes/backend/
   ```

4. **Deploy frontend:**
   ```bash
   kubectl apply -f kubernetes/frontend/
   ```

5. **Check deployments:**
   ```bash
   kubectl get all -n travel-booking
   ```

### Using Ansible Playbooks

1. **Configure inventory:**
   Edit `ansible/inventory/hosts` if needed (default uses localhost)

2. **Deploy all components:**
   ```bash
   cd ansible
   ansible-playbook playbooks/deploy-all.yml
   ```

3. **Or deploy individual components:**
   ```bash
   ansible-playbook playbooks/deploy-database.yml
   ansible-playbook playbooks/deploy-backend.yml
   ansible-playbook playbooks/deploy-frontend.yml
   ```

## Accessing the Application

### Using Minikube

1. **Get service URLs:**
   ```bash
   minikube service frontend-service -n travel-booking --url
   minikube service backend-service -n travel-booking --url
   ```

2. **Or use port-forward:**
   ```bash
   # Frontend
   kubectl port-forward -n travel-booking svc/frontend-service 3000:80
   
   # Backend
   kubectl port-forward -n travel-booking svc/backend-service 8080:8080
   ```

3. **Access the application:**
   - Frontend: http://localhost:3000
   - Backend API: http://localhost:8080

## Useful Kubernetes Commands

### View Resources
```bash
# Get all resources
kubectl get all -n travel-booking

# Get pods
kubectl get pods -n travel-booking

# Get services
kubectl get svc -n travel-booking

# Get deployments
kubectl get deployments -n travel-booking
```

### Debug Commands
```bash
# View pod logs
kubectl logs -n travel-booking <pod-name>

# Describe pod
kubectl describe pod -n travel-booking <pod-name>

# Execute command in pod
kubectl exec -it -n travel-booking <pod-name> -- /bin/bash

# View events
kubectl get events -n travel-booking --sort-by='.lastTimestamp'
```

### Scale Deployments
```bash
# Scale frontend
kubectl scale deployment frontend-deployment -n travel-booking --replicas=3

# Scale backend
kubectl scale deployment backend-deployment -n travel-booking --replicas=2
```

### Update Deployments
```bash
# Restart deployment
kubectl rollout restart deployment/backend-deployment -n travel-booking

# Check rollout status
kubectl rollout status deployment/backend-deployment -n travel-booking

# View rollout history
kubectl rollout history deployment/backend-deployment -n travel-booking
```

## Useful Ansible Commands

### Run Specific Roles
```bash
# Deploy only database
ansible-playbook playbooks/deploy-database.yml

# Deploy only backend
ansible-playbook playbooks/deploy-backend.yml

# Deploy only frontend
ansible-playbook playbooks/deploy-frontend.yml
```

### Check Syntax
```bash
ansible-playbook playbooks/deploy-all.yml --syntax-check
```

### Dry Run
```bash
ansible-playbook playbooks/deploy-all.yml --check
```

### Verbose Mode
```bash
ansible-playbook playbooks/deploy-all.yml -v
ansible-playbook playbooks/deploy-all.yml -vv
ansible-playbook playbooks/deploy-all.yml -vvv
```

## Configuration

### Backend Configuration
Edit `kubernetes/backend/backend-configmap.yaml` or `ansible/roles/backend/vars/main.yml`:
- Database connection settings
- API endpoints
- JWT secret key

### Frontend Configuration
Edit `kubernetes/frontend/frontend-deployment.yaml` or `ansible/roles/frontend/vars/main.yml`:
- Backend API URL
- Port configuration

### Database Configuration
Edit `kubernetes/database/mysql-secret.yaml` or `ansible/roles/database/vars/main.yml`:
- Root password
- Database name
- User credentials

## Cleanup

### Remove all resources
```bash
kubectl delete namespace travel-booking
```

### Or use Ansible
```bash
# You can create a cleanup playbook or run kubectl commands via Ansible
kubectl delete -f kubernetes/
```

### Stop Minikube
```bash
minikube stop
minikube delete
```

## Troubleshooting

### Pods not starting
```bash
# Check pod status
kubectl describe pod <pod-name> -n travel-booking

# Check logs
kubectl logs <pod-name> -n travel-booking

# Check events
kubectl get events -n travel-booking
```

### Service not accessible
```bash
# Check service endpoints
kubectl get endpoints -n travel-booking

# Check service details
kubectl describe svc <service-name> -n travel-booking
```

### Database connection issues
```bash
# Check MySQL pod logs
kubectl logs -n travel-booking mysql-deployment-<pod-id>

# Test database connectivity from backend pod
kubectl exec -it -n travel-booking backend-deployment-<pod-id> -- nc -zv mysql-service 3306
```

## Notes

- Default admin credentials: `demo.admin@demo.com` / `123456`
- The backend uses H2 in-memory database by default in the source. For production, update to use MySQL
- Frontend is configured to connect to backend on port 8080
- All services use ClusterIP by default; use NodePort or LoadBalancer for external access

## License

This deployment configuration is part of the Travel Booking System project.

## Student Information

- **Name**: [Your Name]
- **ID**: 2300031632
- **Lab**: S-218 Lab In-Exam 2
