# Terraform Configuration for AWS IAM Roles

This Terraform configuration creates AWS IAM roles and policies for CodeBuild and CodePipeline that can deploy and manage AWS infrastructure including:

- EC2 instances and VPC components
- Secrets Manager operations
- Lambda functions
- ACM certificates
- ECR repositories and Docker operations
- EventBridge rules
- S3 buckets (for Terraform state)

## Resources Created

### IAM Roles

- **CodeBuild Role**: `${project_name}-${environment}-codebuild-role`
- **CodePipeline Role**: `${project_name}-${environment}-codepipeline-role`

### IAM Policies

- **CodeBuild Policies**: Base policy, EC2/VPC, Secrets Manager, Lambda, ACM, ECR, EventBridge, S3, IAM permissions
- **CodePipeline Policies**: Base policy, CodeCommit, GitHub, SNS notifications

## Prerequisites

### 1. **AWS CLI Configured**

```bash
# Install AWS CLI (if not already installed)
# macOS: brew install awscli

# Configure with your credentials
aws configure
# Enter your AWS Access Key ID, Secret Access Key, and region
```

### 2. **Required AWS Permissions**

Your AWS user needs IAM permissions to create roles and policies. The easiest solution:

**Go to AWS Console → IAM → Users → Find your user → Add permissions → Attach policies:**

- Attach **`PowerUserAccess`** policy (recommended)

**Or have an admin run:**

```bash
aws iam attach-user-policy \
  --user-name YOUR_USERNAME \
  --policy-arn arn:aws:iam::aws:policy/PowerUserAccess
```

### 3. **Verify Setup**

```bash
# Test your credentials and permissions
aws sts get-caller-identity

# Check permissions (optional)
chmod +x check-permissions.sh
./check-permissions.sh
```

## Quick Start

### Deploy the IAM Roles

1. **Initialize Terraform:**

```bash
terraform init
```

2. **Review what will be created:**

```bash
terraform plan
```

3. **Deploy the resources:**

```bash
terraform apply
```

4. **Note the outputs** - you'll get the role ARNs that can be used in CodeBuild/CodePipeline projects.

## Configuration

### Variables

You can customize the deployment by creating a `terraform.tfvars` file:

```hcl
aws_region   = "us-east-1"
project_name = "terraform-cicd"
environment  = "dev"

tags = {
  ManagedBy   = "Terraform"
  Environment = "dev"
  Team        = "DevOps"
  Project     = "Infrastructure"
}
```

### Default Values

- `aws_region`: us-east-1
- `project_name`: terraform-cicd
- `environment`: dev

## Outputs

After successful deployment, you'll get:

- `codebuild_role_arn`: ARN of the CodeBuild role
- `codebuild_role_name`: Name of the CodeBuild role
- `codepipeline_role_arn`: ARN of the CodePipeline role
- `codepipeline_role_name`: Name of the CodePipeline role

## Troubleshooting

### Permission Denied Errors

```bash
# Error: "User is not authorized to perform: iam:CreateRole"
```

**Solution:** Add IAM permissions to your AWS user (see Prerequisites section above)

### Common Issues

- **AWS CLI not configured**: Run `aws configure`
- **Wrong region**: Make sure your CLI region matches your desired deployment region
- **Terraform not found**: Install Terraform locally if needed

## Advanced Configuration

### S3 Backend (Optional)

For team collaboration, you can configure S3 backend for shared state:

```bash
# Use the setup script
chmod +x setup-s3-backend.sh
./setup-s3-backend.sh your-unique-bucket-name us-east-1
```

### CodeBuild Integration (Optional)

Additional CodeBuild integration files are available for when you're ready to set up automated builds.

## Files Description

### Core Terraform Files

- `main.tf`: Main configuration and provider setup
- `variables.tf`: Input variables with defaults
- `iam_roles.tf`: IAM role definitions
- `codebuild_policies.tf`: CodeBuild IAM policies
- `codepipeline_policies.tf`: CodePipeline IAM policies
- `policy_attachments.tf`: Policy-to-role attachments
- `outputs.tf`: Output values

### Configuration Files

- `terraform.tfvars.example`: Example variables file
- `.gitignore`: Git ignore file for Terraform files

### Optional Integration Files

- `setup-s3-backend.sh`: Script to configure S3 backend
- `check-permissions.sh`: Script to verify AWS permissions

## Security Considerations

⚠️ **Important**: These roles have broad permissions for infrastructure management. Consider:

1. **Principle of Least Privilege**: Review and restrict permissions based on your specific needs
2. **Resource-Level Restrictions**: Add resource ARN restrictions where possible
3. **Environment Separation**: Use different roles for different environments
4. **Monitoring**: Enable CloudTrail logging for these roles
5. **Regular Audits**: Periodically review and update permissions

## Next Steps

Once the IAM roles are successfully deployed:

1. Use the role ARNs to create CodeBuild projects
2. Use the role ARNs to create CodePipeline pipelines
3. Consider setting up S3 backend for shared state if working in a team
4. Consider setting up CodeBuild integration for automated deployments
