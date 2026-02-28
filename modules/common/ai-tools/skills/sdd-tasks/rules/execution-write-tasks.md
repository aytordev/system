## Write tasks.md with Phased Hierarchical Checklist

**Impact: CRITICAL**

Transform the analyzed design into a concrete task checklist organized by implementation phase.

### Format

```markdown
# Tasks: {change-name}

## Phase 1: Foundation / Infrastructure
- [ ] 1.1 {Specific task with file path} — {brief description}
- [ ] 1.2 {task}

## Phase 2: Core Implementation
- [ ] 2.1 {task}
- [ ] 2.2 {task}

## Phase 3: Integration / Wiring
- [ ] 3.1 {task}

## Phase 4: Testing
- [ ] 4.1 {task}

## Phase 5: Cleanup / Documentation
- [ ] 5.1 {task}
```

### Phase Organization

**Phase 1: Foundation / Infrastructure**
- Base types, interfaces, schemas
- Database migrations
- Configuration scaffolding
- Dependencies with no dependencies

**Phase 2: Core Implementation**
- Main business logic
- Services, repositories, utilities
- Core algorithms
- Internal components

**Phase 3: Integration / Wiring**
- Middleware hookup
- API route registration
- Component wiring
- External integrations

**Phase 4: Testing**
- Unit tests for core components
- Integration tests for flows
- E2E tests if applicable
- Test data creation

**Phase 5: Cleanup / Documentation**
- Documentation updates
- Migration guides
- Deprecated code removal
- README updates

### Task Numbering

Use hierarchical numbering: `{phase}.{task}` (e.g., `1.1`, `1.2`, `2.1`, `2.2`).

### Task Quality

See `references/task-quality-criteria.md` for what makes a good task.

### Writing to Filesystem

**openspec mode only**: Write to `openspec/changes/{change-name}/tasks.md`.

**engram or none mode**: Tasks are returned in the envelope but not written to disk.
