RFD_DEV_SPACE_HOME := ../../develop-rfd
PROJECT_NAME := library-catalog-ontology
PROJECT_DIR := $(RFD_DEV_SPACE_HOME)/$(PROJECT_NAME)
LCO_DIR := $(PROJECT_DIR)/target/lco
ODK_SCRIPT := $(PROJECT_DIR)/seed-via-docker.sh
CONFIG_FILE := sample-ontology-library-catalog-odk-config.yaml
CONFIG_FILE_PATH := $(PROJECT_DIR)/$(CONFIG_FILE)

# Git repository configuration file
GITREPO_CONFIG_SOURCE := scriptsToShip/Makefile.gitRepo.config
GITREPO_CONFIG_DEST := $(LCO_DIR)/Makefile

USER_CONFIG := user-provided-odk-config.yaml

DOCS_WORKFLOW := $(LCO_DIR)/.github/workflows/docs.yml

# Git configuration (can be overridden)
GIT_AUTHOR_NAME ?= $(shell git config user.name 2>/dev/null || echo "")
GIT_AUTHOR_EMAIL ?= $(shell git config user.email 2>/dev/null || echo "")

.PHONY: help setup clean status check-config check-git

help:
	@echo "Available targets:"
	@echo "  setup       - Complete setup (requires user-provided-odk-config.yml and Git config)"
	@echo "  status      - Show project status"
	@echo "  clean       - Remove project"
	@echo "  check-config - Check if user config file exists"
	@echo "  check-git   - Check Git configuration"
	@echo ""
	@echo "Git configuration:"
	@echo "  Set Git user: git config --global user.name 'Your Name'"
	@echo "  Set Git email: git config --global user.email 'your.email@example.com'"
	@echo "  Or use: make setup GIT_AUTHOR_NAME='Your Name' GIT_AUTHOR_EMAIL='your@email.com'"

setup: $(LCO_DIR) $(GITREPO_CONFIG_DEST) $(DOCS_WORKFLOW)
	@echo "Setup complete!"

check-config:
	@test -f $(USER_CONFIG) || { echo "Error: $(USER_CONFIG) not found. Please create this file first."; exit 1; }
	@echo "User config file found: $(USER_CONFIG)"

check-git:
	@if [ -z "$(GIT_AUTHOR_NAME)" ]; then \
		echo "Error: Git user.name not set."; \
		echo "Run: git config --global user.name 'Your Name'"; \
		echo "Or: make setup GIT_AUTHOR_NAME='Your Name' GIT_AUTHOR_EMAIL='your@email.com'"; \
		exit 1; \
	fi
	@if [ -z "$(GIT_AUTHOR_EMAIL)" ]; then \
		echo "Error: Git user.email not set."; \
		echo "Run: git config --global user.email 'your.email@example.com'"; \
		echo "Or: make setup GIT_AUTHOR_NAME='Your Name' GIT_AUTHOR_EMAIL='your@email.com'"; \
		exit 1; \
	fi
	@echo "Git configuration OK: $(GIT_AUTHOR_NAME) <$(GIT_AUTHOR_EMAIL)>"

$(PROJECT_DIR):
	@echo "Creating project directory"
	@mkdir -p $(PROJECT_DIR)

$(ODK_SCRIPT): $(PROJECT_DIR)
	@echo "Downloading ODK script"
	@curl -L  https://github.com/INCATools/ontology-development-kit/raw/master/seed-via-docker.sh > $(ODK_SCRIPT)
	@chmod +x $(ODK_SCRIPT)

$(CONFIG_FILE_PATH): $(PROJECT_DIR) check-config check-git
	@echo "Copying user config to project directory"
	@cp $(USER_CONFIG) $(CONFIG_FILE_PATH)

$(LCO_DIR): $(ODK_SCRIPT) $(CONFIG_FILE_PATH)
	@echo "Generating ODK structure"
	@cd $(PROJECT_DIR) && \
		ODK_GITNAME="$(GIT_AUTHOR_NAME)" \
		ODK_GITEMAIL="$(GIT_AUTHOR_EMAIL)" \
		./seed-via-docker.sh -c -C $(CONFIG_FILE)

$(GITREPO_CONFIG_DEST): $(PROJECT_DIR)
	@echo "Copying git repository config to project directory"
	@test -f $(GITREPO_CONFIG_SOURCE) || { echo "Error: $(GITREPO_CONFIG_SOURCE) not found"; exit 1; }
	@cp $(GITREPO_CONFIG_SOURCE) $(GITREPO_CONFIG_DEST)
	@echo "Git repository config copied to: $(GITREPO_CONFIG_DEST)"

$(DOCS_WORKFLOW): $(LCO_DIR)
	@echo "Updating docs workflow to handle missing mkdocs.yaml"
	@cp scriptsToShip/docs-workflow-template.yml $(DOCS_WORKFLOW)

copy-gitrepo-config: $(GITREPO_CONFIG_DEST)
	@echo "Git repository configuration file copy complete"

status:
	@echo "Project Status:"
	@test -f $(USER_CONFIG) && echo "User config: EXISTS" || echo "User config: MISSING"
	@test -n "$(GIT_AUTHOR_NAME)" && echo "Git name: $(GIT_AUTHOR_NAME)" || echo "Git name: NOT SET"
	@test -n "$(GIT_AUTHOR_EMAIL)" && echo "Git email: $(GIT_AUTHOR_EMAIL)" || echo "Git email: NOT SET"
	@test -d $(PROJECT_DIR) && echo "Project: EXISTS" || echo "Project: MISSING"
	@test -f $(CONFIG_FILE_PATH) && echo "Project config: COPIED" || echo "Project config: MISSING"
	@test -f $(GITREPO_CONFIG_SOURCE) && echo "Git repo config source: EXISTS" || echo "Git repo config source: MISSING"
	@test -f $(GITREPO_CONFIG_DEST) && echo "Git repo config destination: COPIED" || echo "Git repo config: MISSING"
	@test -d $(LCO_DIR) && echo "ODK: GENERATED" || echo "ODK: MISSING"

clean:
	@rm -rf $(PROJECT_DIR)
	@echo "Project removed"

move-odk-generated-ontology:
	@test -d $(PROJECT_DIR) || { echo "Error: Project directory $(PROJECT_DIR) does not exist run make setup"; exit 1; }
	@echo "Project: EXISTS"
	@echo "Moving ODK generated ontology to developOntologies"
	@rm -rf ~/workspace/ai-apps/developOntologies/*
	@cp -r $(RFD_DEV_SPACE_HOME)/* ~/workspace/ai-apps/developOntologies
	@echo "ODK generated ontology moved to developOntologies"