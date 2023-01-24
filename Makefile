GITLAB_DOMAIN = gitlab.sikalabs.com
GITLAB_PROJECT_ID = 373
STATE_NAME = main

terraform-fmt:
	terraform fmt -recursive

terraform-fmt-check:
	terraform fmt -recursive -check

terraform-providers-lock:
	terraform providers lock \
		-platform=darwin_arm64 \
		-platform=darwin_amd64 \
		-platform=linux_arm64 \
		-platform=linux_amd64
	git add .terraform.lock.hcl
	git commit -m "deps: Update .terraform.lock.hcl" .terraform.lock.hcl

terraform-init-state:
ifndef GITLAB_USERNAME
	$(error GITLAB_USERNAME is undefined)
endif
ifndef GITLAB_TOKEN
	$(error GITLAB_TOKEN is undefined)
endif
	terraform init \
		-backend-config="address=https://${GITLAB_DOMAIN}/api/v4/projects/${GITLAB_PROJECT_ID}/terraform/state/${STATE_NAME}" \
		-backend-config="lock_address=https://${GITLAB_DOMAIN}/api/v4/projects/${GITLAB_PROJECT_ID}/terraform/state/${STATE_NAME}/lock" \
		-backend-config="unlock_address=https://${GITLAB_DOMAIN}/api/v4/projects/${GITLAB_PROJECT_ID}/terraform/state/${STATE_NAME}/lock" \
		-backend-config="username=${GITLAB_USERNAME}" \
		-backend-config="password=${GITLAB_TOKEN}" \
		-backend-config="lock_method=POST" \
		-backend-config="unlock_method=DELETE" \
		-backend-config="retry_wait_min=5"

setup-git-hooks:
	rm -rf .git/hooks
	(cd .git && ln -s ../.git-hooks hooks)
