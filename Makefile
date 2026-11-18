DIRS := $(shell find modules examples -name versions.tf -o -name main.tf | xargs -n1 dirname | sort -u)

.PHONY: fmt validate lint check

fmt:
	terraform fmt -recursive

validate:
	@for d in $(DIRS); do \
		echo "==> $$d"; \
		(cd $$d && terraform init -backend=false -input=false >/dev/null && terraform validate) || exit 1; \
	done

lint:
	tflint --init
	@for d in $(DIRS); do tflint --chdir=$$d --config=$(CURDIR)/.tflint.hcl || exit 1; done

check: fmt validate lint
