#!/bin/bash

# AWS CodeBuild and CodePipeline Deployment Script
# This script deploys the CodeBuild project and CodePipeline

set -e

# Configuration
STACK_NAME="helloworld-react-pipeline"
REGION="us-east-1"  # Change to your preferred region
PROJECT_NAME="helloworld-react"

echo "🚀 Starting deployment of AWS CodeBuild and CodePipeline..."

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI is not installed. Please install it first."
    exit 1
fi

# Check if AWS credentials are configured
if ! aws sts get-caller-identity &> /dev/null; then
    echo "❌ AWS credentials are not configured. Please run 'aws configure' first."
    exit 1
fi

echo "✅ AWS CLI and credentials verified"

# Deploy CodeBuild project first
echo "📦 Deploying CodeBuild project..."
aws cloudformation deploy \
    --template-file codebuild-template.yml \
    --stack-name "${STACK_NAME}-codebuild" \
    --capabilities CAPABILITY_NAMED_IAM \
    --parameter-overrides \
        ProjectName="${PROJECT_NAME}-build" \
        Environment="dev" \
        ECRRepositoryName="${PROJECT_NAME}" \
    --region "${REGION}"

echo "✅ CodeBuild project deployed successfully"

# Get the CodeBuild project name from the stack output
CODEBUILD_PROJECT=$(aws cloudformation describe-stacks \
    --stack-name "${STACK_NAME}-codebuild" \
    --region "${REGION}" \
    --query 'Stacks[0].Outputs[?OutputKey==`CodeBuildProjectName`].OutputValue' \
    --output text)

echo "📋 CodeBuild project name: ${CODEBUILD_PROJECT}"

# Deploy CodePipeline
echo "🔗 Deploying CodePipeline..."
aws cloudformation deploy \
    --template-file codepipeline-template.yml \
    --stack-name "${STACK_NAME}-pipeline" \
    --capabilities CAPABILITY_NAMED_IAM \
    --parameter-overrides \
        ProjectName="${PROJECT_NAME}" \
        CodeBuildProjectName="${CODEBUILD_PROJECT}" \
    --region "${REGION}"

echo "✅ CodePipeline deployed successfully"

# Get the website URL
WEBSITE_URL=$(aws cloudformation describe-stacks \
    --stack-name "${STACK_NAME}-pipeline" \
    --region "${REGION}" \
    --query 'Stacks[0].Outputs[?OutputKey==`WebsiteURL`].OutputValue' \
    --output text)

# Get the ECR repository URI
ECR_REPO_URI=$(aws cloudformation describe-stacks \
    --stack-name "${STACK_NAME}-codebuild" \
    --region "${REGION}" \
    --query 'Stacks[0].Outputs[?OutputKey==`ECRRepositoryURI`].OutputValue' \
    --output text)

echo ""
echo "🎉 Deployment completed successfully!"
echo ""
echo "📋 Stack Information:"
echo "   CodeBuild Stack: ${STACK_NAME}-codebuild"
echo "   CodePipeline Stack: ${STACK_NAME}-pipeline"
echo "   CodeBuild Project: ${CODEBUILD_PROJECT}"
echo "   ECR Repository URI: ${ECR_REPO_URI}"
echo ""
echo "🌐 Website URL: ${WEBSITE_URL}"
echo ""
echo "📚 Next steps:"
echo "   1. Push your code to the source repository"
echo "   2. The pipeline will automatically trigger on code changes"
echo "   3. Monitor the build process in the AWS Console"
echo "   4. Your React app will be deployed to S3 as a static website"
