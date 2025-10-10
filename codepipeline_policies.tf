# IAM Policies for CodePipeline

# Base CodePipeline policy
resource "aws_iam_policy" "codepipeline_base_policy" {
  name        = "${var.project_name}-${var.environment}-codepipeline-base-policy"
  description = "Base policy for CodePipeline service"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetBucketVersioning",
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "codebuild:BatchGetBuilds",
          "codebuild:StartBuild"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "cloudformation:CreateStack",
          "cloudformation:DeleteStack",
          "cloudformation:DescribeStacks",
          "cloudformation:UpdateStack",
          "cloudformation:CreateChangeSet",
          "cloudformation:DeleteChangeSet",
          "cloudformation:DescribeChangeSet",
          "cloudformation:ExecuteChangeSet",
          "cloudformation:SetStackPolicy",
          "cloudformation:ValidateTemplate"
        ]
        Resource = "*"
      }
    ]
  })

  tags = var.tags
}

# CodeCommit permissions for CodePipeline (if using CodeCommit as source)
resource "aws_iam_policy" "codepipeline_codecommit_policy" {
  name        = "${var.project_name}-${var.environment}-codepipeline-codecommit-policy"
  description = "Policy for CodeCommit operations"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "codecommit:GetBranch",
          "codecommit:GetCommit",
          "codecommit:GetRepository",
          "codecommit:ListBranches",
          "codecommit:ListRepositories"
        ]
        Resource = "*"
      }
    ]
  })

  tags = var.tags
}

# GitHub permissions for CodePipeline (if using GitHub as source)
resource "aws_iam_policy" "codepipeline_github_policy" {
  name        = "${var.project_name}-${var.environment}-codepipeline-github-policy"
  description = "Policy for GitHub operations"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "codestar-connections:UseConnection"
        ]
        Resource = "*"
      }
    ]
  })

  tags = var.tags
}

# SNS permissions for CodePipeline notifications
resource "aws_iam_policy" "codepipeline_sns_policy" {
  name        = "${var.project_name}-${var.environment}-codepipeline-sns-policy"
  description = "Policy for SNS operations"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = "*"
      }
    ]
  })

  tags = var.tags
}