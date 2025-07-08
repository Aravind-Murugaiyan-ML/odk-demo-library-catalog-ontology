# Template Files Copy Makefile
# Copies template files to workflow directory

# Configuration Variables
RFD_DEV_SPACE_HOME := ../../develop-rfd
PROJECT_NAME := library-catalog-ontology
PROJECT_DIR := $(RFD_DEV_SPACE_HOME)/$(PROJECT_NAME)
DOMAIN := lco
WORKFLOW_DIR := $(PROJECT_DIR)/target/$(DOMAIN)
TEMPLATE_DIR := $(WORKFLOW_DIR)/src/ontology/templates

# Source directories
SOURCE_TEMPLATE_DIR := templates
SOURCE_SCRIPTS_DIR := scriptsToShip

# Template files to copy
TEMPLATE_FILES := classes.tsv properties.tsv sample-data.tsv

# Source and destination file paths for templates
SOURCE_FILES := $(addprefix $(SOURCE_TEMPLATE_DIR)/, $(TEMPLATE_FILES))
DEST_FILES := $(addprefix $(TEMPLATE_DIR)/, $(TEMPLATE_FILES))

# File Mappings:
SOURCE_MAKEFILE := $(SOURCE_SCRIPTS_DIR)/Makefile
DEST_MAKEFILE := $(WORKFLOW_DIR)/src/ontology/lco.Makefile

.PHONY: all copy-all copy-templates copy-makefile copy-classes copy-properties copy-sample-data clean clean-makefile clean-all help check-source check-dest setup-dirs

# Default target
all: copy-all

# Copy all files (templates and Makefile)
copy-all: copy-templates copy-makefile
	@echo "✅ All files copied successfully"
	@echo "📁 Templates destination: $(TEMPLATE_DIR)"
	@echo "📁 Makefile destination: $(WORKFLOW_DIR)"

# Copy all template files
copy-templates: setup-dirs $(DEST_FILES)
	@echo "✅ All template files copied successfully"
	@echo "📁 Destination: $(TEMPLATE_DIR)"

# Copy Makefile
copy-makefile: setup-dirs $(DEST_MAKEFILE)
	@echo "✅ Makefile copied successfully"
	@echo "📁 Destination: $(WORKFLOW_DIR)"

# Create necessary directories
setup-dirs:
	@echo "📁 Setting up directories..."
	@mkdir -p $(WORKFLOW_DIR)
	@mkdir -p $(TEMPLATE_DIR)
	@mkdir -p $(dir $(DEST_MAKEFILE))
	@echo "✅ Directory created: $(WORKFLOW_DIR)"
	@echo "✅ Directory created: $(TEMPLATE_DIR)"
	@echo "✅ Directory created: $(dir $(DEST_MAKEFILE))"

# Individual copy targets
copy-classes: $(TEMPLATE_DIR)/classes.tsv

copy-properties: $(TEMPLATE_DIR)/properties.tsv

copy-sample-data: $(TEMPLATE_DIR)/sample-data.tsv

# Generic rule for copying template files
$(TEMPLATE_DIR)/%.tsv: $(SOURCE_TEMPLATE_DIR)/%.tsv | setup-dirs
	@if [ -f "$<" ]; then \
		echo "  ↳ Copying $< to $@"; \
		cp "$<" "$@"; \
		echo "✅ Copied: $(notdir $<)"; \
	else \
		echo "❌ Source file not found: $<"; \
		exit 1; \
	fi

# Rule for copying Makefile
$(DEST_MAKEFILE): $(SOURCE_MAKEFILE) | setup-dirs
	@if [ -f "$<" ]; then \
		echo "  ↳ Copying $< to $@"; \
		cp "$<" "$@"; \
		echo "✅ Copied: template.seeding.Makefile → lco.Makefile"; \
	else \
		echo "❌ Source Makefile not found: $<"; \
		exit 1; \
	fi

# Check if source files exist
check-source:
	@echo "🔍 Checking source template files..."
	@for file in $(SOURCE_FILES); do \
		if [ -f "$$file" ]; then \
			echo "✅ Found: $$file"; \
		else \
			echo "❌ Missing: $$file"; \
		fi; \
	done
	@echo "🔍 Checking source Makefile..."
	@if [ -f "$(SOURCE_MAKEFILE)" ]; then \
		echo "✅ Found: $(SOURCE_MAKEFILE)"; \
	else \
		echo "❌ Missing: $(SOURCE_MAKEFILE)"; \
	fi

# Check destination directory and files
check-dest:
	@echo "🔍 Checking destination..."
	@if [ -d "$(WORKFLOW_DIR)" ]; then \
		echo "✅ Workflow directory exists: $(WORKFLOW_DIR)"; \
	else \
		echo "⚠️  Workflow directory doesn't exist: $(WORKFLOW_DIR)"; \
	fi
	@if [ -d "$(TEMPLATE_DIR)" ]; then \
		echo "✅ Template directory exists: $(TEMPLATE_DIR)"; \
		for file in $(DEST_FILES); do \
			if [ -f "$$file" ]; then \
				echo "✅ Found: $$file"; \
			else \
				echo "⚠️  Not found: $$file"; \
			fi; \
		done; \
	else \
		echo "⚠️  Template directory doesn't exist: $(TEMPLATE_DIR)"; \
	fi
	@if [ -f "$(DEST_MAKEFILE)" ]; then \
		echo "✅ Found: $(DEST_MAKEFILE)"; \
	else \
		echo "⚠️  Not found: $(DEST_MAKEFILE)"; \
	fi

# Compare source and destination files
compare:
	@echo "🔍 Comparing source and destination files..."
	@for file in $(TEMPLATE_FILES); do \
		src="$(SOURCE_TEMPLATE_DIR)/$$file"; \
		dest="$(TEMPLATE_DIR)/$$file"; \
		if [ -f "$$src" ] && [ -f "$$dest" ]; then \
			if cmp -s "$$src" "$$dest"; then \
				echo "✅ $$file: Files are identical"; \
			else \
				echo "⚠️  $$file: Files differ"; \
			fi; \
		elif [ -f "$$src" ]; then \
			echo "⚠️  $$file: Source exists, destination missing"; \
		elif [ -f "$$dest" ]; then \
			echo "⚠️  $$file: Destination exists, source missing"; \
		else \
			echo "❌ $$file: Neither source nor destination exists"; \
		fi; \
	done
	@echo "🔍 Comparing Makefile..."
	@if [ -f "$(SOURCE_MAKEFILE)" ] && [ -f "$(DEST_MAKEFILE)" ]; then \
		if cmp -s "$(SOURCE_MAKEFILE)" "$(DEST_MAKEFILE)"; then \
			echo "✅ Makefile: Files are identical"; \
		else \
			echo "⚠️  Makefile: Files differ"; \
		fi; \
	elif [ -f "$(SOURCE_MAKEFILE)" ]; then \
		echo "⚠️  Makefile: Source exists, destination missing"; \
	elif [ -f "$(DEST_MAKEFILE)" ]; then \
		echo "⚠️  Makefile: Destination exists, source missing"; \
	else \
		echo "❌ Makefile: Neither source nor destination exists"; \
	fi

# Force copy (overwrite existing files)
force-copy: setup-dirs
	@echo "🔄 Force copying all files..."
	@for file in $(TEMPLATE_FILES); do \
		src="$(SOURCE_TEMPLATE_DIR)/$$file"; \
		dest="$(TEMPLATE_DIR)/$$file"; \
		if [ -f "$$src" ]; then \
			echo "  ↳ Force copying $$src to $$dest"; \
			cp "$$src" "$$dest"; \
			echo "✅ Force copied: $$file"; \
		else \
			echo "❌ Source file not found: $$src"; \
		fi; \
	done
	@if [ -f "$(SOURCE_MAKEFILE)" ]; then \
		echo "  ↳ Force copying $(SOURCE_MAKEFILE) to $(DEST_MAKEFILE)"; \
		cp "$(SOURCE_MAKEFILE)" "$(DEST_MAKEFILE)"; \
		echo "✅ Force copied: Makefile"; \
	else \
		echo "❌ Source Makefile not found: $(SOURCE_MAKEFILE)"; \
	fi

# Sync files (copy only if source is newer)
sync:
	@echo "🔄 Syncing all files..."
	@for file in $(TEMPLATE_FILES); do \
		src="$(SOURCE_TEMPLATE_DIR)/$$file"; \
		dest="$(TEMPLATE_DIR)/$$file"; \
		if [ -f "$$src" ]; then \
			if [ ! -f "$$dest" ] || [ "$$src" -nt "$$dest" ]; then \
				echo "  ↳ Syncing $$src to $$dest"; \
				mkdir -p "$$(dirname "$$dest")"; \
				cp "$$src" "$$dest"; \
				echo "✅ Synced: $$file"; \
			else \
				echo "⏭️  Skipped (up to date): $$file"; \
			fi; \
		else \
			echo "❌ Source file not found: $$src"; \
		fi; \
	done
	@if [ -f "$(SOURCE_MAKEFILE)" ]; then \
		if [ ! -f "$(DEST_MAKEFILE)" ] || [ "$(SOURCE_MAKEFILE)" -nt "$(DEST_MAKEFILE)" ]; then \
			echo "  ↳ Syncing $(SOURCE_MAKEFILE) to $(DEST_MAKEFILE)"; \
			mkdir -p "$$(dirname "$(DEST_MAKEFILE)")"; \
			cp "$(SOURCE_MAKEFILE)" "$(DEST_MAKEFILE)"; \
			echo "✅ Synced: Makefile"; \
		else \
			echo "⏭️  Skipped (up to date): Makefile"; \
		fi; \
	else \
		echo "❌ Source Makefile not found: $(SOURCE_MAKEFILE)"; \
	fi

# Clean destination template files only (preserve directories)
clean:
	@echo "🧹 Cleaning destination template files..."
	@for file in $(DEST_FILES); do \
		if [ -f "$$file" ]; then \
			echo "  ↳ Removing $$file"; \
			rm -f "$$file"; \
		fi; \
	done
	@echo "✅ Cleaned template files (directories preserved)"

# Clean Makefile only (preserve directories)
clean-makefile:
	@echo "🧹 Cleaning destination Makefile..."
	@if [ -f "$(DEST_MAKEFILE)" ]; then \
		echo "  ↳ Removing $(DEST_MAKEFILE)"; \
		rm -f "$(DEST_MAKEFILE)"; \
		echo "✅ Cleaned Makefile (directories preserved)"; \
	else \
		echo "⚠️  Makefile doesn't exist"; \
	fi

# Clean all copied files only (preserve directory structure)
clean-all:
	@echo "🧹 Cleaning all copied files..."
	@echo "  → Cleaning template files..."
	@for file in $(DEST_FILES); do \
		if [ -f "$$file" ]; then \
			echo "    ↳ Removing $$file"; \
			rm -f "$$file"; \
		fi; \
	done
	@echo "  → Cleaning Makefile..."
	@if [ -f "$(DEST_MAKEFILE)" ]; then \
		echo "    ↳ Removing $(DEST_MAKEFILE)"; \
		rm -f "$(DEST_MAKEFILE)"; \
	fi
	@echo "✅ Cleaned all copied files (directory structure preserved)"

# Show file statistics
stats:
	@echo "📊 Files Statistics:"
	@echo "Source Template Directory: $(SOURCE_TEMPLATE_DIR)"
	@echo "Source Scripts Directory: $(SOURCE_SCRIPTS_DIR)"
	@echo "Destination Template Directory: $(TEMPLATE_DIR)"
	@echo "Destination Workflow Directory: $(WORKFLOW_DIR)"
	@echo ""
	@for file in $(TEMPLATE_FILES); do \
		src="$(SOURCE_TEMPLATE_DIR)/$$file"; \
		dest="$(TEMPLATE_DIR)/$$file"; \
		echo "$$file:"; \
		if [ -f "$$src" ]; then \
			src_size=$$(wc -l < "$$src" 2>/dev/null || echo "0"); \
			echo "  Source: $$src_size lines"; \
		else \
			echo "  Source: Not found"; \
		fi; \
		if [ -f "$$dest" ]; then \
			dest_size=$$(wc -l < "$$dest" 2>/dev/null || echo "0"); \
			echo "  Destination: $$dest_size lines"; \
		else \
			echo "  Destination: Not found"; \
		fi; \
		echo ""; \
	done
	@echo "Makefile:"
	@if [ -f "$(SOURCE_MAKEFILE)" ]; then \
		src_size=$$(wc -l < "$(SOURCE_MAKEFILE)" 2>/dev/null || echo "0"); \
		echo "  Source: $$src_size lines"; \
	else \
		echo "  Source: Not found"; \
	fi
	@if [ -f "$(DEST_MAKEFILE)" ]; then \
		dest_size=$$(wc -l < "$(DEST_MAKEFILE)" 2>/dev/null || echo "0"); \
		echo "  Destination: $$dest_size lines"; \
	else \
		echo "  Destination: Not found"; \
	fi

# Help target
help:
	@echo "📋 Seeding Files Copy Makefile"
	@echo ""
	@echo "Available targets:"
	@echo "  all              - Copy all files (templates + Makefile) (default)"
	@echo "  copy-all         - Copy all files (templates + Makefile)"
	@echo "  copy-templates   - Copy template files only"
	@echo "  copy-makefile    - Copy Makefile only"
	@echo "  copy-classes     - Copy classes.tsv only"
	@echo "  copy-properties  - Copy properties.tsv only"
	@echo "  copy-sample-data - Copy sample-data.tsv only"
	@echo ""
	@echo "Advanced targets:"
	@echo "  force-copy       - Force copy all files (overwrite existing)"
	@echo "  sync             - Copy only if source is newer"
	@echo "  compare          - Compare source and destination files"
	@echo ""
	@echo "Information targets:"
	@echo "  check-source     - Check if source files exist"
	@echo "  check-dest       - Check destination directory and files"
	@echo "  stats            - Show file statistics"
	@echo ""
	@echo "Maintenance targets:"
	@echo "  setup-dirs       - Create destination directories"
	@echo "  clean            - Remove destination template files (preserve dirs)"
	@echo "  clean-makefile   - Remove destination Makefile only (preserve dirs)"
	@echo "  clean-all        - Remove all copied files (preserve directory structure)"
	@echo "  help             - Show this help message"
	@echo ""
	@echo "Configuration:"
	@echo "  SOURCE_TEMPLATE_DIR  = $(SOURCE_TEMPLATE_DIR)"
	@echo "  SOURCE_SCRIPTS_DIR   = $(SOURCE_SCRIPTS_DIR)"
	@echo "  TEMPLATE_DIR         = $(TEMPLATE_DIR)"
	@echo "  WORKFLOW_DIR         = $(WORKFLOW_DIR)"
	@echo "  PROJECT_DIR          = $(PROJECT_DIR)"
	@echo ""
	@echo "File Mappings:"
	@echo "  Templates: $(SOURCE_TEMPLATE_DIR)/*.tsv → $(TEMPLATE_DIR)/*.tsv"
	@echo "  Makefile:  $(SOURCE_MAKEFILE) → $(DEST_MAKEFILE)"
	@echo ""
	@echo "Examples:"
	@echo "  make                     # Copy all files"
	@echo "  make copy-templates      # Copy templates only"
	@echo "  make copy-makefile       # Copy Makefile only"
	@echo "  make sync                # Sync files (copy if newer)"
	@echo "  make force-copy          # Overwrite existing files"
	@echo "  make check-source        # Verify source files exist"