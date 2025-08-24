.PHONY: $(shell sed -n -e '/^$$/ { n ; /^[^ .\#][^ ]*:/ { s/:.*$$// ; p ; } ; }' $(MAKEFILE_LIST))

root_dir := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
meta_project := $(notdir $(patsubst %/,%,$(root_dir)))

help: # Extracts make targets with doble-hash comments and prints them
	@grep -hE '^\S+:.*##' $(MAKEFILE_LIST) | sed -e 's/:.*##\s*/ : /' | while IFS=' : ' read -r cmd desc; do \
		printf "\033[36m%-20s\033[0m %s\n" "$$cmd" "$$desc"; \
	done

meta-update: ## Clone any repos that exist in your .meta file but aren't cloned locally
	@meta git update

pull: ## Run git pull --all --rebase --autostash on all repos
	@meta exec "git pull --all --rebase --autostash" --parallel
