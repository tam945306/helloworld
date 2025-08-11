#!/bin/bash

# Test ECR Repository Script
# This script helps you test the ECR repository by pulling and running the Docker image

set -e

# Configuration
STACK_NAME="helloworld-react-pipeline"
REGION="us-east-1"  # Change to your preferred region
PROJECT_NAME="helloworld-react"

echo "🧪 Testing ECR repository..."

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI is not installed. Please install it first."
    exit 1
fi

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install it first."
    exit 1
fi

# Get the ECR repository URI
ECR_REPO_URI=$(aws cloudformation describe-stacks \
    --stack-name "${STACK_NAME}-codebuild" \
    --region "${REGION}" \
    --query 'Stacks[0].Outputs[?OutputKey==`ECRRepositoryURI`].OutputValue' \
    --output text)

if [ -z "$ECR_REPO_URI" ]; then
    echo "❌ Could not find ECR repository URI. Make sure the stack is deployed."
    exit 1
fi

echo "📋 ECR Repository URI: ${ECR_REPO_URI}"

# Login to ECR
echo "🔐 Logging in to ECR..."
aws ecr get-login-password --region "${REGION}" | docker login --username AWS --password-stdin "${ECR_REPO_URI}"

# Pull the latest image
echo "📥 Pulling latest image from ECR..."
docker pull "${ECR_REPO_URI}:latest"

# Run the container
echo "🚀 Running container from ECR image..."
echo "🌐 The application should be available at http://localhost:3000"
echo "⏹️  Press Ctrl+C to stop the container"

docker run -p 3000:3000 "${ECR_REPO_URI}:latest"
