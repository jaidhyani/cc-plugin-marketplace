---
name: codebase-map
description: Create or update ARCHITECTURE.md - module relationships, entry points, key abstractions
user-invocable: true
---

# Codebase Map

Maintain a navigation aid for the codebase.

## When Invoked

### Step 1: Analyze Structure

Examine:
- Directory structure
- Package/module organization
- Entry points (main files, CLI, API routes)
- Key abstractions (base classes, interfaces, core types)
- Data flow patterns

### Step 2: Find or Create Architecture Doc

Look for:
1. `docs/ARCHITECTURE.md`
2. `ARCHITECTURE.md`
3. `docs/architecture.md`

Create `docs/ARCHITECTURE.md` if none exists.

### Step 3: Generate/Update Content

Structure:

```markdown
# Architecture

## Overview
One paragraph describing what this project does and its main approach.

## Directory Structure
```
src/
  api/          # HTTP endpoints
  core/         # Business logic
  models/       # Data structures
  utils/        # Shared utilities
tests/          # Test files mirror src/
```

## Entry Points
- `src/main.py` - CLI entry point
- `src/api/app.py` - Web server

## Key Abstractions
- `BaseProcessor` - All data processors inherit from this
- `Event` - Core event type used throughout

## Data Flow
1. Request comes in via API
2. Validated by middleware
3. Processed by handler
4. Persisted to database

## Module Dependencies
```
api -> core -> models
      \-> utils
```

## Configuration
- `config.yaml` - Main config
- Environment variables: DATABASE_URL, API_KEY
```

### Step 4: Commit

```bash
git add docs/ARCHITECTURE.md
git commit -m "docs: update architecture documentation"
```

## Notes

- Keep it high-level, not exhaustive
- Update when structure changes significantly
- Focus on "where to look" not "how it works"
