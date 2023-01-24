terraform-providers-lock:
	terraform providers lock \
		-platform=darwin_arm64 \
		-platform=darwin_amd64 \
		-platform=linux_arm64 \
		-platform=linux_amd64
	git add .terraform.lock.hcl
	git commit -m "deps: Update .terraform.lock.hcl" .terraform.lock.hcl
