#!/usr/bin/env bash
set -euo pipefail

echo "=== Verifying Terraform Module ==="

# Validate module syntax
echo "--- terraform fmt check ---"
terraform fmt -check -recursive . || {
  echo "FAIL: Terraform files need formatting. Run 'terraform fmt -recursive .'"
  exit 1
}

echo "--- terraform validate ---"
# Validate without backend to catch syntax issues
terraform init -backend=false && terraform validate

echo ""
echo "=== Verification Complete ==="
