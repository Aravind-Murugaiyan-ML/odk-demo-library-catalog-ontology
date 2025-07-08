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

# All generated files
GENERATED_FILES := $(METRICS_OUTPUT) $(REPORT_OUTPUT) $(ENHANCED_ONTOLOGY) $(ENHANCED_METRICS) $(REASONED_ONTOLOGY) $(CONVERTED_TTL) $(QUERY_FILE) $(EXPORT_CSV) $(NEW_TERMS_TTL) $(NEW_TERMS_OWL)

.PHONY: robot-all robot-help robot-clean robot-clean-all test-robot measure report merge reason convert query export create-terms validate-setup qc workflow stats validate-all examples

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

# Apply reasoning to ontology
reason: $(REASONED_ONTOLOGY)

$(REASONED_ONTOLOGY): $(INPUT_ONTOLOGY)
	@echo "🧠 Applying ELK reasoner..."
	@$(ROBOT) reason --reasoner ELK --input $(INPUT_ONTOLOGY) --output $(REASONED_ONTOLOGY)
	@echo "✅ Success! Generated $(REASONED_ONTOLOGY)"

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

# Quality control workflow
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
	@echo "Option 3: Quality control only"
	@echo "-----------------------------"
	@echo "make measure          # Generate metrics"
	@echo "make report           # Generate quality report"
	@echo "make qc              # Summary of issues"

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
	@echo "  qc               - Quality control check"
	@echo "  workflow         - Complete processing workflow"
	@echo "  validate-all     - Test all operations"
	@echo ""
	@echo "Information:"
	@echo "  stats            - Show ontology statistics"
	@echo "  examples         - Show workflow examples"
	@echo ""
	@echo "Maintenance:"
	@echo "  robot-clean      - Remove generated files"
	@echo "  robot-clean-all  - Remove all temporary files"
	@echo "  robot-help       - Show this help message"
	@echo ""
	@echo "Configuration:"
	@echo "  ROBOT            = docker run ... obolibrary/odkfull robot"
	@echo "  INPUT_ONTOLOGY   = $(INPUT_ONTOLOGY)"
	@echo "  EDIT_ONTOLOGY    = $(EDIT_ONTOLOGY)"
	@echo ""
	@echo "Examples:"
	@echo "  make validate-setup           # Check prerequisites"
	@echo "  make robot-all               # Run basic operations"
	@echo "  make workflow                # Complete workflow"
	@echo "  make qc                      # Quality control"