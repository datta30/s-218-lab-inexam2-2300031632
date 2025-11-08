#!/bin/bash

# Cleanup Script for Travel Booking System

set -e

echo "=========================================="
echo "Travel Booking System Cleanup"
echo "=========================================="

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl not found"
    exit 1
fi

# Confirm deletion
read -p "This will delete all resources in the travel-booking namespace. Continue? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cleanup cancelled"
    exit 0
fi

echo "Deleting namespace and all resources..."
kubectl delete namespace travel-booking

echo "✓ Cleanup complete"
echo ""
echo "To redeploy, run: ./scripts/deploy.sh"
