# Makefile
.PHONY: verify verify-all plan apply destroy docs

verify:
	@echo "=== Quick Verification ==="
	@cd examples && terraform output

verify-all:
	@echo "=== Comprehensive Verification ==="
	@./verify-infra.sh

console:
	@echo "=== AWS Console (LocalStack) ==="
	@open http://localhost:4566/_localstack/cloud

plan:
	@cd examples && terraform plan

apply:
	@cd examples && terraform apply -auto-approve

destroy:
	@cd examples && terraform destroy -auto-approve

docs:
	@terraform-docs markdown table . --output-file README.md

test: verify-all