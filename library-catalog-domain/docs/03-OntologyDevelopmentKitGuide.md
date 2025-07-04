# Library Catalog Ontology Development with ODK

## Step 1: Decision Framework Analysis

### ✅ Not-in-Scope Principle

**Research existing ontologies:**

- **FOAF (Friend of a Friend)** - Has basic concepts for publications but not library-specific
- **Dublin Core** - Metadata terms but not an ontology for library management
- **Schema.org** - Has Book, Author but not library-specific relationships
- **FRBR ontology** - Complex bibliographic model, overkill for our learning case

**Decision**: No existing ontology covers our specific library catalog use case with the simplicity we need for learning.

### ✅ Something Simpler Works Principle

**Could we use alternatives?**

- **Controlled Vocabulary**: Too simple - we need relationships and reasoning
- **Taxonomy**: Missing the relational aspects (writtenBy, publishedBy, etc.)
- **Semantic Data Model**: Could work, but we want to learn ODK specifically

**Decision**: Ontology is appropriate because we want to demonstrate reasoning (e.g., "find all mystery books by authors from UK publishers").

### ✅ Killer Use Case Condition

**Primary Use Case**: Library Management System that can:

- Find books by genre, author, publisher combinations
- Discover relationships (all books by authors who write in multiple genres)
- Reason about availability across library branches
- Support semantic search ("find psychological thrillers published after 2020")

## Step 2: Ontology Design

### Core Classes

```
Library Catalog Ontology (LCO)
├── Agent
│   ├── Author
│   ├── Publisher
│   └── Library
├── InformationResource
│   └── Book
└── Category
    └── Genre
```

### Object Properties

- `writtenBy` (Book → Author)
- `publishedBy` (Book → Publisher)
- `hasGenre` (Book → Genre)
- `availableAt` (Book → Library)
- `employs` (Publisher → Author) [derived]

### Data Properties

- `title` (Book)
- `isbn` (Book)
- `publicationYear` (Book)
- `authorName` (Author)
- `publisherName` (Publisher)
- `libraryName` (Library)
- `genreName` (Genre)

## Step 3: ODK Setup

### Prerequisites Checklist

- [ ] GitHub account created
- [ ] Docker installed and running
- [ ] ODK container pulled: `docker pull obolibrary/odkfull`
- [ ] Docker memory set to at least 8GB
- [ ] Git configured

### Configuration File: `lco-config.yml`

```yaml
# Library Catalog Ontology Configuration
id: lco
title: "Library Catalog Ontology"
description: "An ontology for modeling library catalogs, books, authors, publishers, and their relationships"
github_org: your-github-username
repo: library-catalog-ontology
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
    - id: ro  # Relation Ontology for standard relations
    - id: omo # OBO Metadata Ontology
```

### Repository Creation Commands

```bash
# Create working directory
mkdir library-ontology-project
cd library-ontology-project

# Download ODK wrapper script
curl -L https://github.com/INCATools/ontology-development-kit/raw/master/seed-via-docker.sh > seed-via-docker.sh
chmod +x seed-via-docker.sh

# Create config file
cat > lco-config.yml << 'EOF'
id: lco
title: "Library Catalog Ontology"
description: "An ontology for modeling library catalogs, books, authors, publishers, and their relationships"
github_org: your-github-username
repo: library-catalog-ontology
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
EOF

# Generate repository structure
./seed-via-docker.sh -c lco-config.yml
```

## Step 4: Initial Term Creation

### Robot Template for Core Classes

Create `src/ontology/templates/classes.tsv`:

```tsv
ID	Label	Definition	Parent
LCO:0000001	information resource	A resource that carries information	
LCO:0000002	book	A written or printed work consisting of pages bound together	LCO:0000001
LCO:0000003	agent	An entity that can perform actions	
LCO:0000004	author	A person who writes books	LCO:0000003
LCO:0000005	publisher	An organization that publishes books	LCO:0000003
LCO:0000006	library	An institution that maintains collections of books	LCO:0000003
LCO:0000007	category	A class of things sharing common characteristics	
LCO:0000008	genre	A category of artistic composition characterized by similarities in form, style, or subject matter	LCO:0000007
```

### Robot Template for Object Properties

Create `src/ontology/templates/properties.tsv`:

```tsv
ID	Label	Definition	Domain	Range
LCO:0000100	written by	Relates a book to its author	LCO:0000002	LCO:0000004
LCO:0000101	published by	Relates a book to its publisher	LCO:0000002	LCO:0000005
LCO:0000102	has genre	Relates a book to its genre	LCO:0000002	LCO:0000008
LCO:0000103	available at	Relates a book to libraries where it's available	LCO:0000002	LCO:0000006
```

## Step 5: Sample Data Creation

### Robot Template for Sample Books

Create `src/ontology/templates/sample-books.tsv`:

```tsv
ID	Label	Definition	Parent	written by	published by	has genre
LCO:1000001	The Great Gatsby	A 1925 novel by F. Scott Fitzgerald	LCO:0000002	LCO:2000001	LCO:3000001	LCO:4000001
LCO:1000002	To Kill a Mockingbird	A novel by Harper Lee published in 1960	LCO:0000002	LCO:2000002	LCO:3000002	LCO:4000002
LCO:1000003	1984	A dystopian social science fiction novel by George Orwell	LCO:0000002	LCO:2000003	LCO:3000003	LCO:4000003
```

### Robot Template for Sample Authors

Create `src/ontology/templates/sample-authors.tsv`:

```tsv
ID	Label	Definition	Parent
LCO:2000001	F. Scott Fitzgerald	American novelist and short story writer	LCO:0000004
LCO:2000002	Harper Lee	American novelist	LCO:0000004
LCO:2000003	George Orwell	English novelist and journalist	LCO:0000004
```

## Step 6: Build Process

### Update Makefile

Edit `src/ontology/Makefile` to include your templates:

```makefile
# Add to imports section
$(IMPORTDIR)/template_classes.owl: templates/classes.tsv
	$(ROBOT) template --template $< --prefix "LCO: http://purl.obolibrary.org/obo/LCO_" --output $@

$(IMPORTDIR)/template_properties.owl: templates/properties.tsv
	$(ROBOT) template --template $< --prefix "LCO: http://purl.obolibrary.org/obo/LCO_" --output $@

# Add to main build target
$(ONT).owl: $(SRC) $(IMPORT_FILES) $(IMPORTDIR)/template_classes.owl $(IMPORTDIR)/template_properties.owl
	$(ROBOT) merge --input $(SRC) \
		--input $(IMPORTDIR)/template_classes.owl \
		--input $(IMPORTDIR)/template_properties.owl \
		reason --reasoner ELK \
		annotate --ontology-iri $(ONTBASE)/$(ONT).owl --version-iri $(ONTBASE)/releases/$(TODAY)/$(ONT).owl \
		--output $@.tmp.owl && mv $@.tmp.owl $@
```

### Build Commands

```bash
cd lco/src/ontology

# Generate templates
make imports/template_classes.owl
make imports/template_properties.owl

# Build full ontology
make lco.owl

# Create all release artifacts
make prepare_release
```

## Step 7: Testing and Validation

### Quality Control

```bash
# Run ODK quality control
make test

# Check for consistency
robot reason --reasoner ELK --input lco.owl --output lco-reasoned.owl

# Generate report
robot report --input lco.owl --output reports/lco-report.tsv
```

### Sample SPARQL Queries

Test your ontology with these queries:

```sparql
# Find all books by their authors
SELECT ?book ?author WHERE {
  ?book lco:writtenBy ?author .
}

# Find all mystery books
SELECT ?book WHERE {
  ?book lco:hasGenre lco:mystery .
}

# Find books available at specific library
SELECT ?book ?library WHERE {
  ?book lco:availableAt ?library .
}
```

## Step 8: GitHub Integration

### Push to GitHub

```bash
cd lco
git add .
git commit -m "Initial library catalog ontology structure"

# Create GitHub repository first, then:
git remote add origin https://github.com/your-username/library-catalog-ontology.git
git push -u origin main
```

### GitHub Actions

The ODK automatically creates CI/CD workflows that will:

- Run quality control tests on every commit
- Generate release artifacts
- Validate ontology consistency

## Step 9: Documentation

### Update README.md

````markdown
# Library Catalog Ontology (LCO)

A learning ontology for modeling library catalogs, books, authors, publishers, and their relationships.

## Use Cases
- Library management systems
- Bibliographic databases  
- Book recommendation systems
- Semantic search applications

## Structure
- **Books**: Core information resources
- **Authors**: Creators of books
- **Publishers**: Organizations that publish books
- **Libraries**: Institutions that house books
- **Genres**: Categories for organizing books

## Build Instructions
```bash
cd src/ontology
make prepare_release
````

## License

This ontology is released under CC0.

```

## Step 10: Next Steps for Learning

### Enhancements to Try:
1. **Add more complex classes**: Series, Edition, Translation
2. **Create restrictions**: "Mystery books are only written by mystery authors"
3. **Add data properties**: Publication date, page count, rating
4. **Import external terms**: Use Dublin Core for metadata
5. **Create design patterns**: Standard ways to model book series

### Advanced Features:
1. **Reasoning rules**: Infer that if a book is available at a library, and the library is in a city, then the book is available in that city
2. **SPARQL endpoints**: Set up a triple store for querying
3. **Validation**: SHACL shapes for data quality
4. **Documentation**: Auto-generate documentation with ODK

This ontology provides a solid foundation for learning ODK workflows while being simple enough to understand completely.
```