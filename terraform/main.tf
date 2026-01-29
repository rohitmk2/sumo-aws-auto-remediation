# Terraform configuration
terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }
  }
}

# AWS Provider
provider "aws" {
  region = var.aws_region
}



# Get current AWS account ID
data "aws_caller_identity" "current" {}

# Get latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
  
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


# SNS Topic for notifications
resource "aws_sns_topic" "alerts" {
  name = "ec2-restart-alerts-terraform"
  
  tags = {
    Name        = "EC2 Restart Alerts"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}


# EC2 Instance
resource "aws_instance" "app_server" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"
  
  tags = {
    Name        = "test-instance-terraform"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

# Create ZIP file for Lambda
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/../lambda_function/lambda_function.py"
  output_path = "${path.module}/lambda_deployment.zip"
}


# IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "lambda-ec2-restart-role-terraform"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
  
  tags = {
    Name      = "Lambda EC2 Restart Role"
    ManagedBy = "Terraform"
  }
}


# IAM Policy with LEAST PRIVILEGE
resource "aws_iam_policy" "lambda_policy" {
  name        = "lambda-ec2-restart-least-privilege-terraform"
  description = "Least privilege policy for Lambda to restart specific EC2 instance"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EC2RestartSpecificInstance"
        Effect = "Allow"
        Action = [
          "ec2:RebootInstances"
        ]
        Resource = "arn:aws:ec2:${var.aws_region}:${data.aws_caller_identity.current.account_id}:instance/${aws_instance.app_server.id}"
      },
      {
        Sid      = "EC2DescribeAll"
        Effect   = "Allow"
        Action   = "ec2:DescribeInstances"
        Resource = "*"
      },
      {
        Sid    = "SNSPublishSpecificTopic"
        Effect = "Allow"
        Action = "sns:Publish"
        Resource = aws_sns_topic.alerts.arn
      },
      {
        Sid    = "CloudWatchLogs"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/restart-ec2-terraform:*"
      }
    ]
  })
  
  tags = {
    Name      = "Lambda Least Privilege Policy"
    ManagedBy = "Terraform"
  }
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}


# Lambda Function
resource "aws_lambda_function" "restart_ec2" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "restart-ec2-terraform"
  role            = aws_iam_role.lambda_role.arn
  handler         = "lambda_function.lambda_handler"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime         = "python3.11"
  timeout         = 60
  
  environment {
    variables = {
      INSTANCE_ID   = aws_instance.app_server.id
      SNS_TOPIC_ARN = aws_sns_topic.alerts.arn
    }
  }
  
  tags = {
    Name        = "EC2 Restart Function"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

# Lambda Function URL
resource "aws_lambda_function_url" "restart_url" {
  function_name      = aws_lambda_function.restart_ec2.function_name
  authorization_type = "NONE"
}