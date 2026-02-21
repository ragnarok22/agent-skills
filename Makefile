SHELL := /usr/bin/env bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := help

SKILLS_DIR := skills
CREATE_SKILL_NAME := $(or $(SKILL),$(word 2,$(MAKECMDGOALS)))

ifneq ($(filter create,$(MAKECMDGOALS)),)
  $(foreach goal,$(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS)),$(eval $(goal):;@true))
endif

.PHONY: help create format lint

help: ## Show available targets and usage
	@echo "Usage:"
	@echo "  make help"
	@echo "  make create <skill-name>"
	@echo "  make create SKILL=<skill-name>"
	@echo "  make format"
	@echo "  make lint"
	@echo ""
	@echo "Targets:"
	@awk 'BEGIN {FS = ":.*## "}; /^[a-zA-Z0-9_.-]+:.*## / {printf "  %-12s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

create: ## Create a new skill scaffold under skills/<skill-name>
	@if [[ -z "$(CREATE_SKILL_NAME)" ]]; then \
		echo "Missing skill name."; \
		echo "Usage: make create <skill-name> or make create SKILL=<skill-name>"; \
		exit 1; \
	fi
	@if [[ ! "$(CREATE_SKILL_NAME)" =~ ^[a-z0-9]+(-[a-z0-9]+)*$$ ]]; then \
		echo "Invalid skill name: $(CREATE_SKILL_NAME)"; \
		echo "Use lowercase letters, numbers, and hyphens only."; \
		exit 1; \
	fi
	@skill_dir="$(SKILLS_DIR)/$(CREATE_SKILL_NAME)"; \
	if [[ -d "$$skill_dir" ]]; then \
		echo "Skill already exists: $$skill_dir"; \
		exit 1; \
	fi; \
	mkdir -p "$$skill_dir/agents" "$$skill_dir/scripts" "$$skill_dir/references" "$$skill_dir/assets"; \
	printf "# %s\n\nDescribe what this skill does and when to use it.\n" "$(CREATE_SKILL_NAME)" > "$$skill_dir/SKILL.md"; \
	printf "# %s\n\n## Purpose\n\nShort description of this skill.\n\n## Structure\n\n- `SKILL.md`\n- `agents/openai.yaml`\n- `scripts/` (optional)\n- `references/` (optional)\n- `assets/` (optional)\n" "$(CREATE_SKILL_NAME)" > "$$skill_dir/README.md"; \
	printf "name: %s\ndescription: Describe this skill.\n" "$(CREATE_SKILL_NAME)" > "$$skill_dir/agents/openai.yaml"; \
	echo "Created $$skill_dir"

format: ## Format Markdown and YAML using Prettier (requires npx)
	@if ! command -v npx >/dev/null 2>&1; then \
		echo "npx is required for formatting."; \
		exit 1; \
	fi
	@npx --yes prettier@3 --write README.md AGENTS.md "$(SKILLS_DIR)/**/*.md" "$(SKILLS_DIR)/**/*.yaml"

lint: ## Validate skill naming and required files
	@echo "Checking skill directory names..."
	@bad_dirs="$$(find "$(SKILLS_DIR)" -mindepth 1 -maxdepth 1 -type d -print | sed 's#^$(SKILLS_DIR)/##' | grep -Ev '^[a-z0-9]+(-[a-z0-9]+)*$$' || true)"; \
	if [[ -n "$$bad_dirs" ]]; then \
		echo "Invalid skill directories:"; \
		echo "$$bad_dirs"; \
		exit 1; \
	fi
	@echo "Checking required files..."
	@missing_files="$$(find "$(SKILLS_DIR)" -mindepth 1 -maxdepth 1 -type d -print | while read -r dir; do \
		[[ -f "$$dir/SKILL.md" ]] || echo "$$dir/SKILL.md"; \
		[[ -f "$$dir/agents/openai.yaml" ]] || echo "$$dir/agents/openai.yaml"; \
	done)"; \
	if [[ -n "$$missing_files" ]]; then \
		echo "Missing required files:"; \
		echo "$$missing_files"; \
		exit 1; \
	fi
	@echo "Checking for empty Markdown files..."
	@empty_md="$$(find "$(SKILLS_DIR)" -type f -name '*.md' -size 0 -print)"; \
	if [[ -n "$$empty_md" ]]; then \
		echo "Empty Markdown files found:"; \
		echo "$$empty_md"; \
		exit 1; \
	fi
	@echo "Lint passed."
