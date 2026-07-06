#!/usr/bin/env bash
set -euo pipefail

echo "=== Setting up LocalStack for tf-aws-webapp-ha ==="

export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1
ENDPOINT="http://localhost:4566"

# Create S3 bucket for Terraform state
echo "--- Creating S3 bucket: tf-aws-webapp-ha-state ---"
aws s3 mb s3://tf-aws-webapp-ha-state --endpoint-url=$ENDPOINT 2>/dev/null || echo "Bucket already exists"

# Create DynamoDB table for state locking
echo "--- Creating DynamoDB table: terraform-locks ---"
aws dynamodb create-table \
  --table-name terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --endpoint-url=$ENDPOINT 2>/dev/null || echo "Table already exists"

echo ""
echo "=== LocalStack setup complete ==="
echo "Run: terraform init"
