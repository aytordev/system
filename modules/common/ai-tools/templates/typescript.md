# TypeScript Project

## Stack

- **Language:** TypeScript (strict mode)
- **Runtime:** Node.js / Bun
- **Package Manager:** pnpm (preferred) or npm

## Style Rules

- Prefer `const` over `let`, never use `var`
- Use explicit return types on exported functions
- Prefer interfaces over type aliases for object shapes
- Use `unknown` instead of `any`; narrow with type guards
- Prefer `readonly` arrays and properties where mutation is not needed
- Use template literals over string concatenation
- Prefer `async/await` over raw Promise chains

## File Conventions

- `kebab-case.ts` for files, `PascalCase` for classes/interfaces/types
- `*.test.ts` or `*.spec.ts` colocated with source files
- `index.ts` for barrel exports only (no logic)

## Error Handling

- Use `Result<T, E>` pattern or discriminated unions for expected errors
- Reserve `throw` for truly exceptional/unrecoverable situations
- Always type caught errors as `unknown` and narrow before use

## Testing

- Use Vitest or Jest with `describe`/`it` blocks
- Prefer `toEqual` over `toBe` for object comparisons
- Mock external dependencies, not internal modules
- Aim for behavior-driven tests, not implementation-detail tests

## AI Agent Notes

- Run `tsc --noEmit` before committing to catch type errors
- Use `npx eslint --fix` for lint auto-fixes
- Check `tsconfig.json` for project-specific compiler options
- Look at `package.json` scripts before inventing build commands
