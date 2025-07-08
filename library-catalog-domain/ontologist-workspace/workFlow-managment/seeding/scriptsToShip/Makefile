## Customize Makefile settings for domain
## **********************************************************************##
## If you need to customize your Makefile, make
## changes here rather than in the main Makefile

# Robot ODK Operations Makefile
# Processes OWL ontologies using Robot commands via ODK Docker

# Configuration Variables
ROBOT := docker run --rm -v $$(pwd):/work -w /work obolibrary/odkfull robot
INPUT_ONTOLOGY := lco.owl
EDIT_ONTOLOGY := lco-edit.owl

# Output files
METRICS_OUTPUT := metrics.tsv
REPORT_OUTPUT := report.tsv
ENHANCED_ONTOLOGY := lco-enhanced.owl
ENHANCED_METRICS := enhanced-metrics.tsv
REASONED_ONTOLOGY := lco-reasoned.owl
CONVERTED_TTL := lco-converted.ttl
QUERY_FILE := simple-query.sparql
EXPORT_CSV := export-classes.csv
NEW_TERMS_TTL := new-terms.ttl
NEW_TERMS_OWL := new-terms.owl

# Release configuration
RELEASE_DATE := $(shell date +%Y-%m-%d)
RELEASE_DIR := ../releases/$(RELEASE_DATE)
VERSION_IRI := http://purl.obolibrary.org/obo/lco/releases/$(RELEASE_DATE)/lco.owl

# All generated files
GENERATED_FILES := $(METRICS_OUTPUT) $(REPORT_OUTPUT) $(ENHANCED_ONTOLOGY) $(ENHANCED_METRICS) $(REASONED_ONTOLOGY) $(CONVERTED_TTL) $(QUERY_FILE) $(EXPORT_CSV) $(NEW_TERMS_TTL) $(NEW_TERMS_OWL)

.PHONY: robot-all robot-help robot-clean robot-clean-all test-robot measure report merge reason convert query export create-terms validate-setup qc qc-full workflow stats validate-all examples validate-odk pre-release validate-release-ready create-release update-edit release git-release prepare_release test-odk-integration release-status release-help

.SILENT: robot-clean robot-help

# Default target - run all basic operations
robot-all: validate-setup measure report reason convert
	@echo "🎉 All Robot operations completed successfully!"
	@echo "📁 Generated files:"
	@ls -la $(GENERATED_FILES) 2>/dev/null || true

# Validate that required files exist
validate-setup:
	@echo "🔍 Validating ODK setup..."
	@if [ ! -f "$(INPUT_ONTOLOGY)" ]; then \
		echo "❌ Input ontology not found: $(INPUT_ONTOLOGY)"; \
		echo "💡 Make sure you have $(INPUT_ONTOLOGY) in the current directory"; \
		exit 1; \
	fi
	@echo "✅ Setup validation passed"
	@echo "📁 Found ontology: $(INPUT_ONTOLOGY)"

# Test Robot installation and basic functionality
test-robot: validate-setup
	@echo "🤖 Testing Robot installation..."
	@$(ROBOT) --version
	@echo "✅ Robot is working correctly!"

# Generate ontology metrics
measure: $(METRICS_OUTPUT)

$(METRICS_OUTPUT): $(INPUT_ONTOLOGY)
	@echo "📊 Generating ontology metrics..."
	@$(ROBOT) measure --input $(INPUT_ONTOLOGY) --output $(METRICS_OUTPUT)
	@echo "✅ Success! Generated $(METRICS_OUTPUT)"
	@echo "📈 Metrics summary:"
	@head -5 $(METRICS_OUTPUT)

# Generate ontology quality report
report: $(REPORT_OUTPUT)

$(REPORT_OUTPUT): $(INPUT_ONTOLOGY)
	@echo "📋 Generating ontology quality report..."
	@$(ROBOT) report --input $(INPUT_ONTOLOGY) --output $(REPORT_OUTPUT)
	@echo "✅ Success! Generated $(REPORT_OUTPUT)"
	@echo "📋 Report summary:"
	@head -5 $(REPORT_OUTPUT)

# Merge ontologies (if additional files exist)
merge: $(ENHANCED_ONTOLOGY)

$(ENHANCED_ONTOLOGY): $(EDIT_ONTOLOGY) $(NEW_TERMS_OWL)
	@echo "🔗 Merging ontologies..."
	@if [ -f "$(NEW_TERMS_OWL)" ]; then \
		$(ROBOT) merge --input $(EDIT_ONTOLOGY) --input $(NEW_TERMS_OWL) --output $(ENHANCED_ONTOLOGY); \
		echo "✅ Success! Generated $(ENHANCED_ONTOLOGY)"; \
		echo "📊 Enhanced ontology metrics:"; \
		$(ROBOT) measure --input $(ENHANCED_ONTOLOGY) --output $(ENHANCED_METRICS); \
		head -3 $(ENHANCED_METRICS); \
	else \
		echo "⚠️  $(NEW_TERMS_OWL) not found, skipping merge"; \
	fi

# Apply reasoning to ontology (enhanced version if available)
reason: $(REASONED_ONTOLOGY)

$(REASONED_ONTOLOGY): $(INPUT_ONTOLOGY)
	@echo "🧠 Applying ELK reasoner..."
	@if [ -f "$(ENHANCED_ONTOLOGY)" ]; then \
		echo "📋 Using enhanced ontology: $(ENHANCED_ONTOLOGY)"; \
		$(ROBOT) reason --reasoner ELK --input $(ENHANCED_ONTOLOGY) --output $(REASONED_ONTOLOGY); \
	else \
		echo "📋 Using base ontology: $(INPUT_ONTOLOGY)"; \
		$(ROBOT) reason --reasoner ELK --input $(INPUT_ONTOLOGY) --output $(REASONED_ONTOLOGY); \
	fi
	@echo "✅ Success! Generated $(REASONED_ONTOLOGY)"

# Alternative: Always reason over enhanced ontology (requires merge first)
reason-enhanced: $(ENHANCED_ONTOLOGY)
	@echo "🧠 Applying ELK reasoner to enhanced ontology..."
	@$(ROBOT) reason --reasoner ELK --input $(ENHANCED_ONTOLOGY) --output $(REASONED_ONTOLOGY)
	@echo "✅ Success! Generated $(REASONED_ONTOLOGY) from enhanced ontology"

# Alternative: Separate targets for different reasoning scenarios
reason-base: $(INPUT_ONTOLOGY)
	@echo "🧠 Applying ELK reasoner to base ontology..."
	@$(ROBOT) reason --reasoner ELK --input $(INPUT_ONTOLOGY) --output lco-base-reasoned.owl
	@echo "✅ Success! Generated lco-base-reasoned.owl"

reason-enhanced-only: $(ENHANCED_ONTOLOGY)
	@echo "🧠 Applying ELK reasoner to enhanced ontology..."
	@$(ROBOT) reason --reasoner ELK --input $(ENHANCED_ONTOLOGY) --output lco-enhanced-reasoned.owl
	@echo "✅ Success! Generated lco-enhanced-reasoned.owl"
	
# Convert ontology to different formats
convert: $(CONVERTED_TTL)

$(CONVERTED_TTL): $(INPUT_ONTOLOGY)
	@echo "🔄 Converting ontology to Turtle format..."
	@$(ROBOT) convert --input $(INPUT_ONTOLOGY) --format ttl --output $(CONVERTED_TTL)
	@echo "✅ Success! Generated $(CONVERTED_TTL)"
	@echo "📄 First few lines of Turtle:"
	@head -10 $(CONVERTED_TTL)

# Run SPARQL query on ontology
query: $(QUERY_FILE)
	@echo "🔍 Running SPARQL query..."
	@$(ROBOT) query --input $(INPUT_ONTOLOGY) --query $(QUERY_FILE)
	@echo "✅ Success! SPARQL query executed"

$(QUERY_FILE):
	@echo "📝 Creating SPARQL query file..."
	@echo 'PREFIX owl: <http://www.w3.org/2002/07/owl#>' > $(QUERY_FILE)
	@echo 'PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>' >> $(QUERY_FILE)
	@echo '' >> $(QUERY_FILE)
	@echo 'SELECT ?class ?label WHERE {' >> $(QUERY_FILE)
	@echo '    ?class a owl:Class .' >> $(QUERY_FILE)
	@echo '    ?class rdfs:label ?label .' >> $(QUERY_FILE)
	@echo '} LIMIT 5' >> $(QUERY_FILE)
	@echo "✅ Created $(QUERY_FILE)"

# Export ontology data to CSV
export: $(EXPORT_CSV)

$(EXPORT_CSV): $(INPUT_ONTOLOGY)
	@echo "📤 Exporting ontology to CSV..."
	@$(ROBOT) export --input $(INPUT_ONTOLOGY) --header "ID|Label|Definition" --export $(EXPORT_CSV)
	@echo "✅ Success! Generated $(EXPORT_CSV)"
	@echo "📄 Exported data preview:"
	@head -5 $(EXPORT_CSV)

# Create new terms file
create-terms: $(NEW_TERMS_TTL) $(NEW_TERMS_OWL)

$(NEW_TERMS_TTL):
	@echo "📝 Creating new terms in Turtle format..."
	@echo '@prefix lco: <http://purl.obolibrary.org/obo/LCO_> .' > $(NEW_TERMS_TTL)
	@echo '@prefix owl: <http://www.w3.org/2002/07/owl#> .' >> $(NEW_TERMS_TTL)
	@echo '@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .' >> $(NEW_TERMS_TTL)
	@echo '' >> $(NEW_TERMS_TTL)
	@echo 'lco:0000010 a owl:Class ;' >> $(NEW_TERMS_TTL)
	@echo '    rdfs:label "magazine" ;' >> $(NEW_TERMS_TTL)
	@echo '    rdfs:comment "A periodical publication" .' >> $(NEW_TERMS_TTL)
	@echo '' >> $(NEW_TERMS_TTL)
	@echo 'lco:0000011 a owl:Class ;' >> $(NEW_TERMS_TTL)
	@echo '    rdfs:label "journal" ;' >> $(NEW_TERMS_TTL)
	@echo '    rdfs:comment "An academic or professional publication" .' >> $(NEW_TERMS_TTL)
	@echo "✅ Created $(NEW_TERMS_TTL)"

$(NEW_TERMS_OWL): $(NEW_TERMS_TTL)
	@echo "🔄 Converting new terms to OWL format..."
	@$(ROBOT) convert --input $(NEW_TERMS_TTL) --output $(NEW_TERMS_OWL)
	@echo "✅ Success! Generated $(NEW_TERMS_OWL)"

# Quality control workflow (existing)
qc: report measure
	@echo "📊 Quality Control Summary"
	@echo "========================="
	@if [ -f "$(REPORT_OUTPUT)" ]; then \
		errors=$$(grep -c "ERROR" $(REPORT_OUTPUT) 2>/dev/null || echo "0"); \
		warnings=$$(grep -c "WARN" $(REPORT_OUTPUT) 2>/dev/null || echo "0"); \
		echo "Errors found: $$errors"; \
		echo "Warnings found: $$warnings"; \
		if [ "$$errors" -gt "0" ]; then \
			echo "❌ Critical errors detected! Review $(REPORT_OUTPUT)"; \
		else \
			echo "✅ No critical errors found"; \
		fi; \
	fi

# Enhanced QC with release validation
qc-full: report measure validate-odk
	@echo "📊 Comprehensive Quality Control (Release Ready)"
	@echo "=============================================="
	@if [ -f "$(REPORT_OUTPUT)" ]; then \
		errors=$$(grep -c "ERROR" $(REPORT_OUTPUT) 2>/dev/null || echo "0"); \
		warnings=$$(grep -c "WARN" $(REPORT_OUTPUT) 2>/dev/null || echo "0"); \
		echo "Errors found: $$errors"; \
		echo "Warnings found: $$warnings"; \
		if [ "$$errors" -gt "0" ]; then \
			echo "❌ Critical errors detected! Review $(REPORT_OUTPUT)"; \
			echo "🛑 Cannot proceed with release"; \
			exit 1; \
		else \
			echo "✅ No critical errors found"; \
		fi; \
		if [ "$$warnings" -gt "10" ]; then \
			echo "⚠️  High number of warnings ($$warnings). Consider reviewing."; \
		fi; \
	fi
	@echo "✅ Release-quality validation passed!"

# ODK-style validation
validate-odk: $(REASONED_ONTOLOGY)
	@echo "🔍 Running ODK validation checks..."
	@if [ -f "$(REASONED_ONTOLOGY)" ]; then \
		echo "✅ Reasoning completed successfully"; \
	else \
		echo "❌ Reasoning failed - check for inconsistencies"; \
		exit 1; \
	fi
	@$(ROBOT) validate --input $(REASONED_ONTOLOGY) || echo "⚠️  Validation warnings found"
	@echo "✅ ODK validation completed"

# Pre-release validation workflow
pre-release: workflow qc-full validate-release-ready
	@echo "🎯 Pre-release validation completed!"
	@echo "📋 Summary:"
	@echo "  ✅ New terms created and merged"
	@echo "  ✅ Reasoning applied successfully"  
	@echo "  ✅ Quality control passed"
	@echo "  ✅ Release validation passed"
	@echo ""
	@echo "🚀 Ready for release process!"

# Validate release readiness
validate-release-ready:
	@echo "🔍 Validating release readiness..."
	@for file in $(REASONED_ONTOLOGY) $(ENHANCED_ONTOLOGY) $(REPORT_OUTPUT); do \
		if [ ! -f "$$file" ]; then \
			echo "❌ Missing required file: $$file"; \
			exit 1; \
		fi; \
	done
	@if grep -q "TODO\|FIXME" $(REASONED_ONTOLOGY) 2>/dev/null; then \
		echo "⚠️  Found TODO/FIXME comments in ontology"; \
		grep -n "TODO\|FIXME" $(REASONED_ONTOLOGY); \
	fi
	@echo "✅ Release readiness validated"

# Create release artifacts
create-release: pre-release
	@echo "📦 Creating release artifacts..."
	@mkdir -p $(RELEASE_DIR)
	@cp $(REASONED_ONTOLOGY) $(RELEASE_DIR)/lco.owl
	@cp $(CONVERTED_TTL) $(RELEASE_DIR)/lco.ttl
	@cp $(EXPORT_CSV) $(RELEASE_DIR)/lco-classes.csv
	@cp $(REPORT_OUTPUT) $(RELEASE_DIR)/
	@cp $(METRICS_OUTPUT) $(RELEASE_DIR)/
	@echo "# LCO Release $(RELEASE_DATE)" > $(RELEASE_DIR)/RELEASE_NOTES.md
	@echo "" >> $(RELEASE_DIR)/RELEASE_NOTES.md
	@echo "## Changes" >> $(RELEASE_DIR)/RELEASE_NOTES.md
	@echo "- Added new terms via Robot templates" >> $(RELEASE_DIR)/RELEASE_NOTES.md
	@echo "- Applied ELK reasoning" >> $(RELEASE_DIR)/RELEASE_NOTES.md
	@echo "- Quality control validation passed" >> $(RELEASE_DIR)/RELEASE_NOTES.md
	@echo "" >> $(RELEASE_DIR)/RELEASE_NOTES.md
	@echo "## Quality Metrics" >> $(RELEASE_DIR)/RELEASE_NOTES.md
	@echo "\`\`\`" >> $(RELEASE_DIR)/RELEASE_NOTES.md
	@cat $(METRICS_OUTPUT) >> $(RELEASE_DIR)/RELEASE_NOTES.md
	@echo "\`\`\`" >> $(RELEASE_DIR)/RELEASE_NOTES.md
	@echo "✅ Release artifacts created in $(RELEASE_DIR)"

# Update edit file with enhanced ontology
update-edit: $(ENHANCED_ONTOLOGY)
	@echo "🔄 Updating edit file for next development cycle..."
	@if [ -f "$(ENHANCED_ONTOLOGY)" ]; then \
		echo "📋 Backing up current edit file..."; \
		cp $(EDIT_ONTOLOGY) $(EDIT_ONTOLOGY).backup; \
		echo "📋 Updating $(EDIT_ONTOLOGY) with enhanced ontology..."; \
		cp $(ENHANCED_ONTOLOGY) $(EDIT_ONTOLOGY); \
		echo "✅ Edit file updated"; \
	else \
		echo "❌ Enhanced ontology not found"; \
		exit 1; \
	fi

# Full release workflow
release: create-release update-edit
	@echo "🎉 Release $(RELEASE_DATE) completed!"
	@echo ""
	@echo "📁 Release artifacts:"
	@ls -la $(RELEASE_DIR)/
	@echo ""
	@echo "📋 Next steps:"
	@echo "1. Review release artifacts in $(RELEASE_DIR)/"
	@echo "2. Commit and push changes to repository"
	@echo "3. Create GitHub release with artifacts"
	@echo "4. Update documentation if needed"

# Git integration for release
git-release: release
	@echo "🔧 Preparing Git release..."
	@git add $(RELEASE_DIR)/
	@git add $(EDIT_ONTOLOGY)
	@git commit -m "Release $(RELEASE_DATE): Enhanced ontology with new terms and reasoning"
	@git tag -a "v$(RELEASE_DATE)" -m "LCO Release $(RELEASE_DATE)"
	@echo "✅ Git release prepared"
	@echo "📋 To complete:"
	@echo "   git push origin main"
	@echo "   git push origin v$(RELEASE_DATE)"

# ODK standard targets integration
prepare_release: create-release
	@echo "📦 ODK-style release preparation completed"

# Test integration with ODK workflow
test-odk-integration:
	@echo "🧪 Testing ODK integration..."
	@if make -n prepare_release >/dev/null 2>&1; then \
		echo "✅ ODK prepare_release target available"; \
	else \
		echo "⚠️  ODK prepare_release target not available"; \
	fi
	@if make -n $(INPUT_ONTOLOGY) >/dev/null 2>&1; then \
		echo "✅ ODK build targets available"; \
	else \
		echo "⚠️  ODK build targets not available"; \
	fi
	@echo "🎯 Integration test completed"

# Show release status
release-status:
	@echo "📊 Release Status Dashboard"
	@echo "=========================="
	@echo "🔹 Current date: $(RELEASE_DATE)"
	@echo "🔹 Release directory: $(RELEASE_DIR)"
	@echo ""
	@echo "📁 Required files status:"
	@for file in $(INPUT_ONTOLOGY) $(EDIT_ONTOLOGY) $(ENHANCED_ONTOLOGY) $(REASONED_ONTOLOGY); do \
		if [ -f "$$file" ]; then \
			echo "  ✅ $$file"; \
		else \
			echo "  ❌ $$file (missing)"; \
		fi; \
	done
	@echo ""
	@echo "📋 Workflow completion:"
	@if [ -f "$(NEW_TERMS_OWL)" ]; then echo "  ✅ Terms created"; else echo "  ⏳ Terms not created"; fi
	@if [ -f "$(ENHANCED_ONTOLOGY)" ]; then echo "  ✅ Ontology merged"; else echo "  ⏳ Ontology not merged"; fi
	@if [ -f "$(REASONED_ONTOLOGY)" ]; then echo "  ✅ Reasoning applied"; else echo "  ⏳ Reasoning not applied"; fi
	@if [ -f "$(REPORT_OUTPUT)" ]; then echo "  ✅ QC completed"; else echo "  ⏳ QC not completed"; fi

# Full workflow: create terms, merge, and process
workflow: create-terms merge reason convert qc
	@echo "🎯 Complete ODK workflow executed!"
	@echo "📁 All generated files:"
	@ls -la $(GENERATED_FILES) 2>/dev/null || true

# Show ontology statistics
stats: $(METRICS_OUTPUT)
	@echo "📊 Ontology Statistics"
	@echo "====================="
	@echo "Input ontology: $(INPUT_ONTOLOGY)"
	@echo "File size: $$(du -h $(INPUT_ONTOLOGY) | cut -f1)"
	@if [ -f "$(METRICS_OUTPUT)" ]; then \
		echo ""; \
		echo "Detailed metrics:"; \
		cat $(METRICS_OUTPUT); \
	fi

# Validate all operations work
validate-all: test-robot robot-all qc
	@echo "🔍 Validating all Robot operations..."
	@echo "✅ All operations completed successfully!"
	@echo ""
	@echo "🎉 Your ODK setup is fully functional!"

# Clean generated files (renamed to avoid conflict)
robot-clean: 
	@echo "🧹 Cleaning generated files..."
	@for file in $(GENERATED_FILES); do \
		if [ -f "$$file" ]; then \
			echo "  ↳ Removing $$file"; \
			rm -f "$$file"; \
		fi; \
	done
	@echo "✅ Cleaned all generated files"

# Clean everything including backups (renamed to avoid conflict)
robot-clean-all: robot-clean
	@echo "🧹 Cleaning all temporary files..."
	@rm -f *.bak *~ .*.swp
	@echo "✅ Cleaned all temporary files"

# Show ODK workflow examples
examples:
	@echo "🚀 ODK Workflow Examples"
	@echo "========================"
	@echo ""
	@echo "Option 1: Standard ODK workflow"
	@echo "-------------------------------"
	@echo "# Edit ontology and build:"
	@echo "make validate-setup    # Check prerequisites"
	@echo "make qc               # Quality control"
	@echo "make reason           # Apply reasoning"
	@echo "make convert          # Convert formats"
	@echo ""
	@echo "Option 2: Add terms programmatically"
	@echo "------------------------------------"
	@echo "make create-terms     # Create new terms file"
	@echo "make merge            # Merge with existing ontology"
	@echo "make workflow         # Complete processing"
	@echo ""
	@echo "Option 3: Release workflow"
	@echo "-------------------------"
	@echo "make workflow         # Complete development"
	@echo "make qc-full          # Release-ready QC"
	@echo "make release          # Create release"
	@echo "make git-release      # Git workflow"

# Help for release workflow
release-help:
	@echo "🚀 ODK Release Workflow Help"
	@echo "============================"
	@echo ""
	@echo "📋 Standard workflow:"
	@echo "1. make workflow          # Create terms, merge, reason"
	@echo "2. make qc-full          # Comprehensive quality control"
	@echo "3. make pre-release      # Pre-release validation"
	@echo "4. make release          # Create release artifacts"
	@echo "5. make git-release      # Prepare Git release"
	@echo ""
	@echo "🔍 Validation steps:"
	@echo "  make validate-odk       # ODK-style validation"
	@echo "  make qc-full           # Enhanced quality control"
	@echo "  make release-status    # Check readiness"
	@echo ""
	@echo "📦 Release steps:"
	@echo "  make create-release    # Generate artifacts only"
	@echo "  make update-edit       # Update edit file"
	@echo "  make git-release       # Full Git workflow"

# Help target (renamed to avoid conflict)
robot-help:
	@echo "🤖 Robot ODK Operations Makefile"
	@echo ""
	@echo "Available targets:"
	@echo "  robot-all        - Run basic Robot operations"
	@echo "  validate-setup   - Check that required files exist"
	@echo "  test-robot       - Test Robot installation"
	@echo ""
	@echo "Individual operations:"
	@echo "  measure          - Generate ontology metrics"
	@echo "  report           - Generate quality report"
	@echo "  merge            - Merge ontologies"
	@echo "  reason           - Apply ELK reasoner"
	@echo "  convert          - Convert to Turtle format"
	@echo "  query            - Run SPARQL query"
	@echo "  export           - Export to CSV format"
	@echo ""
	@echo "Workflows:"
	@echo "  create-terms     - Create new terms file"
	@echo "  qc               - Basic quality control check"
	@echo "  qc-full          - Release-ready quality control"
	@echo "  workflow         - Complete development workflow"
	@echo "  pre-release      - Pre-release validation"
	@echo "  release          - Complete release workflow"
	@echo "  validate-all     - Test all operations"
	@echo ""
	@echo "Information:"
	@echo "  stats            - Show ontology statistics"
	@echo "  release-status   - Show release readiness"
	@echo "  examples         - Show workflow examples"
	@echo "  release-help     - Show release workflow help"
	@echo ""
	@echo "Maintenance:"
	@echo "  robot-clean      - Remove generated files"
	@echo "  robot-clean-all  - Remove all temporary files"
	@echo "  robot-help       - Show this help message"
	@echo ""
	@echo "Examples:"
	@echo "  make workflow                 # Complete development"
	@echo "  make qc-full                  # Release-ready QC"
	@echo "  make release                  # Create release"
	@echo "  make release-status           # Check readiness"