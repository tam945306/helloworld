# AWS CodeBuild Pipeline with ECR Integration

This project sets up a complete CI/CD pipeline using AWS CodeBuild and CodePipeline that builds your React application, creates a Docker image, and pushes it to Amazon ECR.

## 🏗️ Architecture

The pipeline consists of:
- **CodeBuild Project**: Builds the React app and Docker image, pushes to ECR
- **CodePipeline**: Orchestrates the entire CI/CD process
- **ECR Repository**: Stores Docker images with lifecycle policies
- **S3 Buckets**: Store build artifacts and serve the static website

## 📋 Prerequisites

- AWS CLI installed and configured
- Docker installed locally (for testing)
- Node.js 18+ (for local development)
- AWS account with appropriate permissions

## 🚀 Quick Start

### 1. Deploy the Infrastructure

```bash
# Make the deployment script executable
chmod +x deploy.sh

# Deploy the stacks
./deploy.sh
```

This will create:
- CodeBuild project with ECR integration
- CodePipeline for CI/CD
- ECR repository for Docker images
- S3 buckets for artifacts and deployment

### 2. Push Your Code

```bash
# Add your files
git add .

# Commit changes
git commit -m "Initial commit"

# Push to trigger the pipeline
git push origin main
```

### 3. Monitor the Build

- Check the CodeBuild console for build status
- View logs in CloudWatch
- Monitor the pipeline in the CodePipeline console

## 🔧 Configuration

### Environment Variables

The CodeBuild project uses these environment variables:
- `ENVIRONMENT`: Build environment (dev/staging/prod)
- `AWS_DEFAULT_REGION`: AWS region for the build
- `ECR_REPOSITORY_URI`: ECR repository URI
- `IMAGE_TAG`: Docker image tag (default: latest)

### Customization

You can customize the pipeline by modifying:
- `buildspec.yml`: Build steps and commands
- `codebuild-template.yml`: CodeBuild configuration
- `codepipeline-template.yml`: Pipeline stages and actions
- `deploy.sh`: Deployment parameters

## 🐳 Docker Image

### Image Details
- **Base Image**: Node.js 18 Alpine
- **Port**: 3000
- **Entry Point**: Serves the built React app using `serve`

### ECR Repository
- **Name**: `helloworld-react` (configurable)
- **Lifecycle Policy**: Keeps last 5 images, expires older ones
- **Image Scanning**: Enabled for security

## 🧪 Testing

### Test ECR Repository Locally

```bash
# Make the test script executable
chmod +x test-ecr.sh

# Test the ECR repository
./test-ecr.sh
```

This script will:
1. Pull the latest image from ECR
2. Run the container locally
3. Make the app available at http://localhost:3000

### Manual Testing

```bash
# Login to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <ECR_REPO_URI>

# Pull image
docker pull <ECR_REPO_URI>:latest

# Run container
docker run -p 3000:3000 <ECR_REPO_URI>:latest
```

## 📁 File Structure

```
.
├── buildspec.yml              # CodeBuild configuration
├── codebuild-template.yml     # CodeBuild CloudFormation template
├── codepipeline-template.yml  # CodePipeline CloudFormation template
├── deploy.sh                  # Deployment script
├── test-ecr.sh               # ECR testing script
├── Dockerfile                 # Docker configuration
├── package.json               # Node.js dependencies
└── src/                       # React source code
```

## 🔍 Troubleshooting

### Common Issues

1. **Build Fails**: Check CodeBuild logs in CloudWatch
2. **ECR Push Fails**: Verify IAM permissions and ECR repository exists
3. **Pipeline Stuck**: Check CodePipeline console for stage failures
4. **Docker Build Fails**: Ensure Dockerfile is correct and dependencies are available

### Debugging

```bash
# Check stack status
aws cloudformation describe-stacks --stack-name helloworld-react-pipeline-codebuild

# View CodeBuild logs
aws logs describe-log-groups --log-group-name-prefix "/aws/codebuild/"

# Check ECR repository
aws ecr describe-repositories --repository-names helloworld-react
```

## 🔐 Security

- IAM roles use least privilege principle
- ECR repository has image scanning enabled
- S3 buckets have appropriate access controls
- All resources are created in your AWS account

## 💰 Cost Optimization

- CodeBuild uses `BUILD_GENERAL1_SMALL` compute type
- ECR lifecycle policy automatically cleans up old images
- S3 lifecycle policies manage artifact retention
- Consider using Spot instances for cost savings

## 📚 Additional Resources

- [AWS CodeBuild Documentation](https://docs.aws.amazon.com/codebuild/)
- [AWS CodePipeline Documentation](https://docs.aws.amazon.com/codepipeline/)
- [Amazon ECR Documentation](https://docs.aws.amazon.com/ecr/)
- [CloudFormation Documentation](https://docs.aws.amazon.com/cloudformation/)

## 🤝 Contributing

Feel free to submit issues and enhancement requests!

## 📄 License

This project is licensed under the MIT License.
