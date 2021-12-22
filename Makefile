# usage:
# $ make ecr_repo
# $ make init-(dev or prod or etc.)
# $ make plan-(dev or prod or etc.)
# $ make apply-(dev or prod or etc.)
include .env

DC := docker-compose exec terraform
ENV_PROD := .env.production
ENV_GITHUB := .env.github

# aws cliは入っておく。
ecr-repo:
	aws ecr create-repository --repository-name $(TF_VAR_APP_NAME)-app
	aws ecr create-repository --repository-name $(TF_VAR_APP_NAME)-nginx

ssm-store:
	sh ssm-put.sh $(TF_VAR_APP_NAME) .env.production && \
	sh ssm-put.sh $(TF_VAR_APP_NAME) .env

up:
	docker-compose up -d --build
init:
	@${DC} terraform init

plan:
	@${DC} terraform plan

# Make migrate if S3 bucket name is changed.
migrate:
	@${DC} terraform init -migrate-state

# Make resources by terraform
apply:
	@${DC} terraform init
	${DC} terraform apply

# Refresh tfstate if created resources are changed by manually.
refresh:
	@${DC} terraform refresh

# Make state list of resources.
list:
	@${DC} terraform state list

# Destroy terraform resources.
destroy:
	@${DC} terraform destroy

# SSM / Github SECRETに登録する値の用意
outputs:
	@${DC} terraform output -json | ${DC} jq -r '"DB_HOST=\(.db_endpoint.value)"'  > $(ENV_PROD)  && \
	${DC} terraform output -json |  ${DC} jq -r '"REDIS_HOST=\(.redis_hostname.value[0].address)"' >> $(ENV_PROD)  && \
	${DC} terraform output -json |  ${DC} jq -r '"SUBNETS=\(.db_subnets.value)"' > $(ENV_GITHUB) && \
    ${DC} terraform output -json |  ${DC} jq -r '"SECURITY_GROUPS=\(.db_security_groups.value)"' >> $(ENV_GITHUB)