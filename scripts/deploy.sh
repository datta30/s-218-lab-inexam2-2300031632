#!/bin/bash

# Quick Deploy Script for Travel Booking System

set -e

echo "=========================================="
echo "Travel Booking System Quick Deploy"
echo "=========================================="

# Check prerequisites
echo "Checking prerequisites..."

if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl not found. Please install kubectl first."
    exit 1
fi

if ! command -v ansible-playbook &> /dev/null; then
    echo "❌ ansible-playbook not found. Please install Ansible first."
    exit 1
fi

echo "✓ kubectl found"
echo "✓ ansible-playbook found"

# Check cluster connectivity
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Cannot connect to Kubernetes cluster"
    echo "   Please ensure your cluster is running (e.g., minikube start)"
    exit 1
fi

echo "✓ Kubernetes cluster is accessible"

# Choose deployment method
echo ""
echo "Select deployment method:"
echo "1. Deploy using Ansible (Recommended)"
echo "2. Deploy using kubectl directly"
read -p "Enter choice (1 or 2): " choice

case $choice in
    1)
        echo ""
        echo "Deploying using Ansible..."
        cd ansible
        ansible-playbook playbooks/deploy-all.yml
        ;;
    2)
        echo ""
        echo "Deploying using kubectl..."
        kubectl apply -f kubernetes/namespace.yaml
        echo "✓ Namespace created"
        
        kubectl apply -f kubernetes/database/
        echo "✓ Database deployed"
        
        echo "Waiting for database to be ready..."
        kubectl wait --for=condition=ready pod -l app=mysql -n travel-booking --timeout=300s
        
        kubectl apply -f kubernetes/backend/
        echo "✓ Backend deployed"
        
        kubectl apply -f kubernetes/frontend/
        echo "✓ Frontend deployed"
        
        echo "Waiting for all pods to be ready..."
        kubectl wait --for=condition=ready pod --all -n travel-booking --timeout=300s
        ;;
    *)
        echo "Invalid choice"
        exit 1
        ;;
esac

echo ""
echo "=========================================="
echo "Deployment Summary"
echo "=========================================="
kubectl get all -n travel-booking

echo ""
echo "=========================================="
echo "Access URLs"
echo "=========================================="
echo "To access the application:"
echo ""
echo "Frontend:"
if command -v minikube &> /dev/null && minikube status &> /dev/null; then
    FRONTEND_URL=$(minikube service frontend-service -n travel-booking --url 2>/dev/null || echo "N/A")
    echo "  ${FRONTEND_URL}"
else
    echo "  kubectl port-forward -n travel-booking svc/frontend-service 3000:80"
    echo "  Then access: http://localhost:3000"
fi

echo ""
echo "Backend API:"
if command -v minikube &> /dev/null && minikube status &> /dev/null; then
    BACKEND_URL=$(minikube service backend-service -n travel-booking --url 2>/dev/null || echo "N/A")
    echo "  ${BACKEND_URL}"
else
    echo "  kubectl port-forward -n travel-booking svc/backend-service 8080:8080"
    echo "  Then access: http://localhost:8080"
fi

echo ""
echo "=========================================="
echo "Default Admin Credentials"
echo "=========================================="
echo "Email: demo.admin@demo.com"
echo "Password: 123456"
echo "=========================================="
