# Design Document Template

Complete template for technical design documents.

---

# Design: {Change Name}

## Technical Approach

{One paragraph summary of the overall strategy. What are we doing at a high level?}

## Architecture Decisions

### Decision: {Name}

**Choice**: {What we decided to do}

**Alternatives Considered**:
- {Alternative 1 and why it was rejected}
- {Alternative 2 and why it was rejected}

**Rationale**: {Why we chose this approach over the alternatives}

### Decision: {Another Decision}

**Choice**: {What we decided to do}

**Alternatives Considered**:
- {Alternative 1}
- {Alternative 2}

**Rationale**: {Why this choice}

## Data Flow

### {Flow Name}

```
{ASCII diagram showing how data moves through the system}

Example:
User → Frontend → Backend → Database
                    |
                    v
              Validation Layer
                    |
                    v
              Business Logic
```

### {Another Flow}

```
{Another ASCII diagram}
```

## File Changes

| File | Action | Description |
|------|--------|-------------|
| `path/to/file.ext` | CREATE | What this new file does |
| `path/to/existing.ext` | MODIFY | What changes to existing file |
| `path/to/old.ext` | DELETE | Why this file is being removed |

## Interfaces / Contracts

### {Service/Module Name}

```{language}
interface ServiceName {
  methodName(param: Type): ReturnType;
  anotherMethod(param: Type): ReturnType;
}
```

### API Endpoints

```
GET  /api/endpoint         - Description
POST /api/another          - Description
PUT  /api/resource/:id     - Description
```

### Database Schema

```sql
CREATE TABLE table_name (
  id SERIAL PRIMARY KEY,
  field1 VARCHAR(255) NOT NULL,
  field2 INTEGER,
  created_at TIMESTAMP DEFAULT NOW()
);
```

## Testing Strategy

| Layer | What | Approach |
|-------|------|----------|
| Unit | Component/function behavior | Mock dependencies |
| Integration | Module interactions | Real dependencies where possible |
| E2E | Full user flows | Automated browser tests |

## Migration / Rollout

{Only include this section if applicable}

1. {Step 1 — what happens first}
2. {Step 2 — next deployment step}
3. {Step 3 — rollout strategy}
4. {Step 4 — monitoring and validation}

## Open Questions

- [ ] {Question 1 that needs resolution}
- [ ] {Question 2 that needs resolution}
- [ ] {Question 3 that needs resolution}

---

## Usage Notes

- **Technical Approach**: Keep to 1 paragraph, high-level summary
- **Architecture Decisions**: Every decision needs rationale (the "why")
- **Data Flow**: Use simple ASCII diagrams, not complex UML
- **File Changes**: Use concrete paths, not vague descriptions
- **Interfaces**: Show actual code signatures, not pseudocode
- **Testing Strategy**: Cover unit, integration, and E2E layers
- **Migration**: Only include if deployment has special steps
- **Open Questions**: Use checkboxes for easy tracking
