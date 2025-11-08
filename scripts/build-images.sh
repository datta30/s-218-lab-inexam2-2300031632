#!/bin/bash

# Build and Push Docker Images Script for Travel Booking System

set -e

# Configuration
DOCKER_REGISTRY="${DOCKER_REGISTRY:-docker.io}"
DOCKER_USERNAME="${DOCKER_USERNAME:-yourusername}"
IMAGE_TAG="${IMAGE_TAG:-latest}"
BACKEND_IMAGE="${DOCKER_REGISTRY}/${DOCKER_USERNAME}/travel-booking-backend:${IMAGE_TAG}"
FRONTEND_IMAGE="${DOCKER_REGISTRY}/${DOCKER_USERNAME}/travel-booking-frontend:${IMAGE_TAG}"

# Source code paths (adjust these to your actual repository paths)
BACKEND_SOURCE="${BACKEND_SOURCE:-/path/to/travel_booking_backend}"
FRONTEND_SOURCE="${FRONTEND_SOURCE:-/path/to/travel_booking_frontend}"

echo "=========================================="
echo "Building Docker Images"
echo "=========================================="
echo "Backend Image: ${BACKEND_IMAGE}"
echo "Frontend Image: ${FRONTEND_IMAGE}"
echo "=========================================="

# Build backend image
echo "Building backend image..."
if [ -d "$BACKEND_SOURCE" ]; then
    docker build -t "${BACKEND_IMAGE}" -f dockerfiles/Dockerfile.backend "${BACKEND_SOURCE}"
    echo "✓ Backend image built successfully"
else
    echo "⚠ Backend source not found at ${BACKEND_SOURCE}"
    echo "  Please set BACKEND_SOURCE environment variable"
fi

# Build frontend image
echo "Building frontend image..."
if [ -d "$FRONTEND_SOURCE" ]; then
    cp dockerfiles/nginx.conf "${FRONTEND_SOURCE}/"
    docker build -t "${FRONTEND_IMAGE}" -f dockerfiles/Dockerfile.frontend "${FRONTEND_SOURCE}"
    rm "${FRONTEND_SOURCE}/nginx.conf"
    echo "✓ Frontend image built successfully"
else
    echo "⚠ Frontend source not found at ${FRONTEND_SOURCE}"
    echo "  Please set FRONTEND_SOURCE environment variable"
fi

# Push images (optional)
read -p "Push images to registry? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Logging into Docker registry..."
    docker login "${DOCKER_REGISTRY}"
    
    echo "Pushing backend image..."
    docker push "${BACKEND_IMAGE}"
    
    echo "Pushing frontend image..."
    docker push "${FRONTEND_IMAGE}"
    
    echo "✓ Images pushed successfully"
fi

echo "=========================================="
echo "Build Complete!"
echo "=========================================="
echo "To use these images in Kubernetes:"
echo "1. Update kubernetes/backend/backend-deployment.yaml"
echo "   Set image: ${BACKEND_IMAGE}"
echo "2. Update kubernetes/frontend/frontend-deployment.yaml"
echo "   Set image: ${FRONTEND_IMAGE}"
echo "=========================================="
