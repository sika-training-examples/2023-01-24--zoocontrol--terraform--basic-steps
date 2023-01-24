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

setup-git-hooks:
	rm -rf .git/hooks
	(cd .git && ln -s ../.git-hooks hooks)
