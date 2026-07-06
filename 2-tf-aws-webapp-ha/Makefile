# Makefile for tf-aws-webapp-ha

.PHONY: help init plan apply destroy fmt validate lint checkov \
        localstack-setup localstack-init localstack-plan localstack-apply localstack-destroy

ENV ?= dev

# LocalStack connection details
LS_ENV = AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test \
         AWS_DEFAULT_REGION=us-east-1 \
         AWS_ENDPOINT_URL_S3=http://localhost:4566 \
         AWS_ENDPOINT_URL_DYNAMODB=http://localhost:4566

help: ## Show this help message
	@echo 'Usage: make [target] ENV=dev|prod'
	@echo ''
	@echo 'Available targets:'
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

# ---- Real AWS targets ----

init: ## Initialize Terraform (real AWS)
	@cd envs/$(ENV) && terraform init

plan: ## Generate and show plan (real AWS)
	@cd envs/$(ENV) && terraform plan -var-file="terraform.tfvars" -out=plan.tfplan

apply: ## Apply changes (real AWS, requires plan)
	@cd envs/$(ENV) && terraform apply plan.tfplan

destroy: ## Destroy infrastructure (real AWS, use with caution)
	@cd envs/$(ENV) && terraform destroy -var-file="terraform.tfvars"

# ---- LocalStack targets ----

localstack-setup: ## Create S3 bucket and DynamoDB table in LocalStack
	@$(LS_ENV) bash envs/dev/setup-localstack.sh

localstack-init: ## Initialize Terraform with LocalStack backend
	@$(LS_ENV) terraform -chdir=envs/$(ENV) init -reconfigure

localstack-plan: ## Generate and show plan (LocalStack)
	@$(LS_ENV) terraform -chdir=envs/$(ENV) plan -var-file="terraform.tfvars" -out=plan.tfplan

localstack-apply: ## Apply changes (LocalStack)
	@$(LS_ENV) terraform -chdir=envs/$(ENV) apply plan.tfplan

localstack-destroy: ## Destroy infrastructure (LocalStack)
	@$(LS_ENV) terraform -chdir=envs/$(ENV) destroy -var-file="terraform.tfvars"

# ---- Shared targets ----

output: ## Show outputs
	@cd envs/$(ENV) && terraform output

fmt: ## Format Terraform code
	@terraform fmt -recursive

validate: ## Validate Terraform code
	@cd envs/$(ENV) && terraform validate

lint: ## Run TFLint
	@tflint -c .tflint.hcl --recursive

checkov: ## Run Checkov security scan
	@checkov -d . -s

state-list: ## List resources in state
	@cd envs/$(ENV) && terraform state list

console: ## Connect to database (requires bastion)
	@psql -h $$(terraform -chdir=envs/$(ENV) output -raw rds_address) \
		-U $$(terraform -chdir=envs/$(ENV) output -raw db_username) \
		-d $$(terraform -chdir=envs/$(ENV) output -raw db_name)

drift-detect: ## Detect drift (requires AWS CLI)
	@aws configservice start-configuration-recorder --configuration-recorder-name default
	@aws configservice deliver-config-snapshot --delivery-channel-name default
	@echo "Drift detection initiated. Check AWS Config console for results."

clean: ## Remove .terraform directories
	@find . -type d -name ".terraform" -exec rm -rf {} + 2>/dev/null || true
	@find . -type f -name "*.tfplan" -delete

setup-precommit: ## Install pre-commit hooks
	@pip install pre-commit
	@pre-commit install
	@pre-commit install-hooks
