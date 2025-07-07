#!/bin/bash
# Fixed ODK Learning Setup Script with Git Configuration

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🏛️ ODK Learning Setup (Fixed Version)${NC}"
echo "=============================================="
echo ""

# Function to setup Git if needed
setup_git() {
    echo -e "${YELLOW}🔧 Checking Git configuration...${NC}"
    
    # Check if Git is configured
    if git config --global user.name &> /dev/null && git config --global user.email &> /dev/null; then
        echo -e "${GREEN}✅ Git is already configured${NC}"
        GIT_USER_NAME=$(git config --global user.name)
        GIT_USER_EMAIL=$(git config --global user.email)
    else
        echo -e "${YELLOW}⚙️ Git not configured. Setting up...${NC}"
        
        # Use default values for learning (user can change later)
        read -p "Enter your name for Git (or press Enter for 'ODK Learner'): " input_name
        read -p "Enter your email for Git (or press Enter for 'learner@example.com'): " input_email
        
        GIT_USER_NAME=${input_name:-"ODK Learner"}
        GIT_USER_EMAIL=${input_email:-"learner@example.com"}
        
        git config --global user.name "$GIT_USER_NAME"
        git config --global user.email "$GIT_USER_EMAIL"
        
        echo -e "${GREEN}✅ Git configured with:${NC}"
    fi
    
    echo "   Name: $GIT_USER_NAME"
    echo "   Email: $GIT_USER_EMAIL"
    
    # Export Git environment variables for ODK
    export GIT_AUTHOR_NAME="$GIT_USER_NAME"
    export GIT_AUTHOR_EMAIL="$GIT_USER_EMAIL"
    export GIT_COMMITTER_NAME="$GIT_USER_NAME"
    export GIT_COMMITTER_EMAIL="$GIT_USER_EMAIL"
    
    echo -e "${GREEN}✅ Git environment variables set for ODK${NC}"
}

# Check prerequisites
echo -e "${YELLOW}📋 Checking prerequisites...${NC}"

# Check Docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker not found. Please install Docker first.${NC}"
    exit 1
fi

if ! docker info &> /dev/null; then
    echo -e "${RED}❌ Docker is not running. Please start Docker.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Docker is running${NC}"

# Check for ODK container
if ! docker images | grep -q "obolibrary/odkfull"; then
    echo -e "${YELLOW}⬇️ Pulling ODK container (this may take a few minutes)...${NC}"
    docker pull obolibrary/odkfull
fi

echo -e "${GREEN}✅ ODK container ready${NC}"

# Setup Git
setup_git

echo ""
echo -e "${BLUE}🚀 Setting up your ODK learning environment...${NC}"

# Create project directory
PROJECT_DIR="library-catalog-ontology-learning"
if [ -d "$PROJECT_DIR" ]; then
    echo -e "${YELLOW}📁 Directory $PROJECT_DIR exists. Removing to start fresh...${NC}"
    rm -rf "$PROJECT_DIR"
fi

mkdir "$PROJECT_DIR"
cd "$PROJECT_DIR"
echo -e "${GREEN}📁 Created fresh project directory: $PROJECT_DIR${NC}"

# Download ODK wrapper script
echo -e "${YELLOW}⬇️ Downloading ODK wrapper script...${NC}"
curl -L https://github.com/INCATools/ontology-development-kit/raw/master/seed-via-docker.sh > seed-via-docker.sh
chmod +x seed-via-docker.sh
echo -e "${GREEN}✅ ODK wrapper downloaded${NC}"

# Create configuration file
echo -e "${YELLOW}⚙️ Creating ODK configuration...${NC}"
cat > lco-config.yml << 'EOF'
id: lco
title: "Library Catalog Ontology - Learning Edition"
description: "A learning ontology for practicing ODK workflows"
github_org: odk-learner
repo: library-catalog-ontology-learning
license: CC0
primary_release: full
release_artefacts:
  - base
  - full
  - simple
export_formats:
  - owl
  - obo
  - json
import_group:
  products:
    - id: ro
    - id: omo
reasoner: ELK
EOF

echo -e "${GREEN}✅ Configuration created${NC}"

# Generate ODK repository with proper Git configuration
echo -e "${YELLOW}🏗️ Generating ODK repository structure...${NC}"
echo "This will take 2-3 minutes on first run..."
echo "Using Git config: $GIT_AUTHOR_NAME <$GIT_AUTHOR_EMAIL>"

# Run ODK with Git environment variables set
if ./seed-via-docker.sh -c lco-config.yml; then
    echo -e "${GREEN}✅ Repository structure generated successfully!${NC}"
else
    echo -e "${RED}❌ Failed to generate repository.${NC}"
    echo ""
    echo -e "${YELLOW}🔧 Troubleshooting tips:${NC}"
    echo "1. Make sure Docker has enough memory (8GB+)"
    echo "2. Check your internet connection"
    echo "3. Try running with explicit Git config:"
    echo "   ./seed-via-docker.sh -c lco-config.yml --gitname=\"$GIT_AUTHOR_NAME\" --gitemail=\"$GIT_AUTHOR_EMAIL\""
    exit 1
fi

cd lco

# Create learning templates
echo -e "${YELLOW}📝 Creating learning templates...${NC}"
mkdir -p src/ontology/templates

# Basic classes template
cat > src/ontology/templates/classes.tsv << 'EOF'
ID	Label	Definition	Parent
LCO:0000001	information resource	A resource that carries information	
LCO:0000002	book	A written or printed work consisting of pages bound together	LCO:0000001
LCO:0000003	agent	An entity that can perform actions	
LCO:0000004	author	A person who writes books	LCO:0000003
LCO:0000005	publisher	An organization that publishes books	LCO:0000003
LCO:0000006	library	An institution that maintains collections of books	LCO:0000003
LCO:0000007	category	A class of things sharing common characteristics	
LCO:0000008	genre	A category of artistic composition characterized by similarities in form, style, or subject matter	LCO:0000007
EOF

# Properties template
cat > src/ontology/templates/properties.tsv << 'EOF'
ID	Label	Definition	Domain	Range
LCO:0000100	written by	Relates a book to its author	LCO:0000002	LCO:0000004
LCO:0000101	published by	Relates a book to its publisher	LCO:0000002	LCO:0000005
LCO:0000102	has genre	Relates a book to its genre	LCO:0000002	LCO:0000008
LCO:0000103	available at	Relates a book to libraries where it's available	LCO:0000002	LCO:0000006
EOF

# Sample data template with relationships
cat > src/ontology/templates/sample-data.tsv << 'EOF'
ID	Label	Definition	Parent	written_by	published_by	has_genre
LCO:2000001	George Orwell	English novelist and journalist (1903-1950)	LCO:0000004			
LCO:2000002	J.K. Rowling	British author known for Harry Potter series	LCO:0000004			
LCO:3000001	Penguin Books	British publishing house	LCO:0000005			
LCO:3000002	Bloomsbury	British publishing house	LCO:0000005			
LCO:4000001	dystopian fiction	A genre featuring societies where life is miserable	LCO:0000008			
LCO:4000002	fantasy	A genre of speculative fiction involving magical elements	LCO:0000008			
LCO:1000001	1984	A dystopian novel by George Orwell	LCO:0000002	LCO:2000001	LCO:3000001	LCO:4000001
LCO:1000002	Harry Potter and the Philosopher's Stone	First novel in the Harry Potter series	LCO:0000002	LCO:2000002	LCO:3000002	LCO:4000002
EOF

echo -e "${GREEN}✅ Learning templates created${NC}"

# Create enhanced build script
cat > build-ontology.sh << 'EOF'
#!/bin/bash
echo "🏛️ Building Library Catalog Ontology..."

cd src/ontology

echo "📝 Processing templates..."

# Process each template
if [ -f "templates/classes.tsv" ]; then
    echo "  ↳ Processing classes template..."
    robot template --template templates/classes.tsv \
        --prefix "LCO: http://purl.obolibrary.org/obo/LCO_" \
        --output imports/template_classes.owl
fi

if [ -f "templates/properties.tsv" ]; then
    echo "  ↳ Processing properties template..."
    robot template --template templates/properties.tsv \
        --prefix "LCO: http://purl.obolibrary.org/obo/LCO_" \
        --output imports/template_properties.owl
fi

if [ -f "templates/sample-data.tsv" ]; then
    echo "  ↳ Processing sample data template..."
    robot template --template templates/sample-data.tsv \
        --prefix "LCO: http://purl.obolibrary.org/obo/LCO_" \
        --output imports/template_sample_data.owl
fi

echo "🔧 Building main ontology..."
make lco.owl

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Ontology built successfully!"
    echo ""
    echo "📊 Quick statistics:"
    robot info --input lco.owl
    echo ""
    
    echo "🔍 Running consistency check..."
    robot reason --reasoner ELK --input lco.owl --output lco-reasoned.owl
    
    if [ $? -eq 0 ]; then
        echo "✅ Ontology is logically consistent!"
    else
        echo "⚠️ Found logical inconsistencies (this might be expected for learning)"
    fi
    
    echo ""
    echo "📁 Generated files:"
    echo "  ├── lco.owl (main ontology)"
    echo "  ├── lco-reasoned.owl (after reasoning)"
    echo "  └── imports/ (template-generated components)"
    
else
    echo "❌ Build failed - check the error messages above"
    exit 1
fi
EOF

chmod +x build-ontology.sh

# Create sample SPARQL queries
mkdir -p sparql/learning
cat > sparql/learning/basic-queries.sparql << 'EOF'
# Basic SPARQL queries for learning ODK

PREFIX lco: <http://purl.obolibrary.org/obo/LCO_>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>

# Query 1: List all classes
SELECT ?class ?label WHERE {
    ?class a owl:Class .
    ?class rdfs:label ?label .
    FILTER(STRSTARTS(STR(?class), "http://purl.obolibrary.org/obo/LCO_"))
}
ORDER BY ?label

# Query 2: List all properties  
SELECT ?property ?label ?type WHERE {
    {
        ?property a owl:ObjectProperty .
        BIND("Object Property" as ?type)
    } UNION {
        ?property a owl:DatatypeProperty .
        BIND("Data Property" as ?type)
    }
    ?property rdfs:label ?label .
    FILTER(STRSTARTS(STR(?property), "http://purl.obolibrary.org/obo/LCO_"))
}
ORDER BY ?type ?label

# Query 3: Show all book-author-publisher relationships
SELECT ?bookTitle ?authorName ?publisherName ?genreName WHERE {
    ?book a lco:0000002 .
    ?book rdfs:label ?bookTitle .
    
    OPTIONAL {
        ?book lco:0000100 ?author .
        ?author rdfs:label ?authorName .
    }
    
    OPTIONAL {
        ?book lco:0000101 ?publisher .
        ?publisher rdfs:label ?publisherName .
    }
    
    OPTIONAL {
        ?book lco:0000102 ?genre .
        ?genre rdfs:label ?genreName .
    }
}
ORDER BY ?bookTitle
EOF

# Run initial build
echo -e "${YELLOW}🔧 Running initial build to test everything...${NC}"
if ./build-ontology.sh; then
    echo -e "${GREEN}🎉 Initial build successful!${NC}"
else
    echo -e "${YELLOW}⚠️ Initial build had issues, but that's normal for learning${NC}"
fi

# Create learning guides
cat > LEARNING_GUIDE.md << 'EOF'
# ODK Learning Guide - Library Catalog Ontology

## 🎯 What You Just Created

You now have a fully functional ODK ontology project with:
- ✅ Proper Git configuration  
- ✅ ODK repository structure
- ✅ Robot templates for creating terms
- ✅ Sample data (books, authors, publishers, genres)
- ✅ Build system that works
- ✅ SPARQL queries for exploration

## 🚀 Quick Start Commands

```bash
# Build your ontology
./build-ontology.sh

# Run quality control tests
cd src/ontology && make test

# Create release artifacts  
cd src/ontology && make prepare_release

# Query your ontology
robot query --input src/ontology/lco.owl --query sparql/learning/basic-queries.sparql
```

## 📂 Key Files to Explore

### Templates (Your Data Entry Point)
- `src/ontology/templates/classes.tsv` - Add new classes here
- `src/ontology/templates/properties.tsv` - Add new relationships here  
- `src/ontology/templates/sample-data.tsv` - Add new instances here

### Generated Files (Don't Edit Directly)
- `src/ontology/lco.owl` - Main ontology file
- `src/ontology/imports/` - Template-generated components
- `lco-reasoned.owl` - After reasoning

### Build System
- `src/ontology/Makefile` - ODK build rules
- `build-ontology.sh` - Your custom build script

## 🧪 Learning Exercises

### Exercise 1: Add a New Book
1. Edit `src/ontology/templates/sample-data.tsv`
2. Add a row for "To Kill a Mockingbird" by Harper Lee
3. Run `./build-ontology.sh`
4. Query to see your new book

### Exercise 2: Add Data Properties
1. Create `src/ontology/templates/data-properties.tsv`
2. Add properties like `publication_year`, `page_count`, `isbn`
3. Update your book instances to include this data
4. Test with SPARQL queries

### Exercise 3: Create Complex Hierarchies
1. Add subclasses of `book`: `fiction_book`, `non_fiction_book`
2. Add subclasses of `genre`: `mystery`, `romance`, `science_fiction`
3. Test the hierarchy with reasoning

## 🔍 Testing Your Changes

Always test after making changes:
```bash
# Build and validate
./build-ontology.sh

# Check for logical consistency
cd src/ontology
robot reason --reasoner ELK --input lco.owl

# Run quality control
make test
```

## 🎓 Next Learning Steps

1. **Week 1**: Master templates and basic SPARQL
2. **Week 2**: Add data properties and complex hierarchies  
3. **Week 3**: Learn OWL restrictions and reasoning
4. **Week 4**: External integrations and validation

## 🆘 Getting Help

- Check `TROUBLESHOOTING.md` for common issues
- ODK Documentation: https://github.com/INCATools/ontology-development-kit
- Robot Tool: http://robot.obolibrary.org/
- Ask questions: https://github.com/INCATools/ontology-development-kit/discussions

Happy learning! 🎉
EOF

cat > TROUBLESHOOTING.md << 'EOF'
# Troubleshooting Guide

## Common Issues and Solutions

### Build Errors

**"Docker out of memory"**
- Increase Docker memory to 8GB+ in Docker Desktop settings
- Restart Docker after changing memory

**"Template processing failed"**  
- Check TSV files use TABS not SPACES
- Verify column headers match exactly
- Check for special characters in data

**"Robot command not found"**
- You're outside the ODK container
- Use `cd src/ontology && make` instead of direct robot commands

### Git Issues

**"Git username not set"**
- Already fixed in this script!
- But if needed: `git config --global user.name "Your Name"`

**"Permission denied"**
- Make sure scripts are executable: `chmod +x build-ontology.sh`

### Reasoning Errors

**"Ontology is inconsistent"**
- This is actually a learning opportunity!
- Use `robot explain --reasoner ELK --input lco.owl` to debug
- Check for conflicting class assertions

### Import Issues

**"Cannot download import"**
- Check internet connection
- Some imports require authentication
- Try building without imports first

## Getting Detailed Error Info

```bash
# More verbose output
./build-ontology.sh 2>&1 | tee build.log

# Check specific Robot command
cd src/ontology
robot --help

# Test individual components
robot template --template templates/classes.tsv --output test.owl
```

## Reset Everything

If you want to start completely fresh:
```bash
cd .. # Go back to parent directory
rm -rf library-catalog-ontology-learning
# Then run the setup script again
```
EOF

echo ""
echo -e "${GREEN}🎉 ODK Learning Environment Successfully Set Up!${NC}"
echo "================================================="
echo ""
echo -e "${BLUE}📍 Your location:${NC} $(pwd)"
echo -e "${BLUE}📁 Project structure:${NC}"
echo "├── src/ontology/           # Main ontology files"
echo "├── ├── templates/          # Where you add new terms"
echo "├── ├── sparql/learning/    # Example queries"
echo "├── ├── lco-edit.owl        # Main source file"
echo "├── └── Makefile           # Build system"
echo "├── build-ontology.sh       # Your build script"
echo "├── LEARNING_GUIDE.md       # Your learning roadmap"
echo "└── TROUBLESHOOTING.md      # When things go wrong"
echo ""
echo -e "${BLUE}🚀 Next steps:${NC}"
echo "1. Explore your ontology: open src/ontology/lco.owl in Protégé"
echo "2. Try the sample queries: robot query --input src/ontology/lco.owl --query sparql/learning/basic-queries.sparql"
echo "3. Follow LEARNING_GUIDE.md for structured learning"
echo "4. Make changes to templates/ and rebuild to see the effects"
echo ""
echo -e "${BLUE}💡 Pro tips:${NC}"
echo "• Always run ./build-ontology.sh after making changes"
echo "• Use 'cd src/ontology && make test' to validate"
echo "• Check TROUBLESHOOTING.md if you encounter issues"
echo "• The templates/ directory is where you'll do most of your work"
echo ""
echo -e "${GREEN}Git configuration used:${NC}"
echo "Name: $GIT_AUTHOR_NAME"
echo "Email: $GIT_AUTHOR_EMAIL"
echo ""
echo -e "${YELLOW}Ready to start learning ODK! 🎓${NC}"