GITLAB_DOMAIN = gitlab.sikalabs.com
GITLAB_PROJECT_ID = 373

publish:
ifndef NAME
	$(error NAME is undefined)
endif
ifndef SYSTEM
	$(error SYSTEM is undefined)
endif
ifndef VERSION
	$(error VERSION is undefined)
endif
ifndef GITLAB_TOKEN
	$(error GITLAB_TOKEN is undefined)
endif
	tar -czf ${NAME}-${SYSTEM}-${VERSION}.tgz -C ${NAME} .
	curl --fail-with-body --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" \
		--upload-file ${NAME}-${SYSTEM}-${VERSION}.tgz \
		"https://${GITLAB_DOMAIN}/api/v4/projects/${GITLAB_PROJECT_ID}/packages/terraform/modules/${NAME}/${SYSTEM}/${VERSION}/file"

docs:
ifndef NAME
	$(error NAME is undefined)
endif
	(cd ${NAME} && terraform-docs markdown table . > README.md)
	git add ${NAME}/README.md
	git commit -m "docs(modules/${NAME}): Update Terraform module README.md" ${NAME}/README.md
