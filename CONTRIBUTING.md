# 🚀 Contributing to System Infrastructure

Thank you for your interest in contributing to our infrastructure project! This guide explains how to collaborate effectively, whether you're a human contributor or an AI-assisted tool.

## 📋 Table of Contents

- [🌟 Welcome](#-welcome)
  - [Project Overview](#project-overview)
  - [How to Contribute](#how-to-contribute)
  - [First Time? Start Here](#first-time-start-here)
- [🔍 Contribution Workflow](#-contribution-workflow)
  - [1. Find or Create an Issue](#1-find-or-create-an-issue)
  - [2. Set Up Your Environment](#2-set-up-your-environment)
  - [3. Make Your Changes](#3-make-your-changes)
  - [4. Commit with Gitmoji](#4-commit-with-gitmoji)
  - [5. Submit a Pull Request](#5-submit-a-pull-request)
  - [6. Code Review](#6-code-review)
  - [7. After Approval](#7-after-approval)
- [🤖 AI-Assisted Contributions](#-ai-assisted-contributions)
  - [Guidelines for AI Tools](#guidelines-for-ai-tools)
  - [Best Practices](#best-practices)
  - [Common Pitfalls](#common-pitfalls)
- [📌 Issue Management](#-issue-management)
  - [Bug Reports](#bug-reports)
  - [Feature Requests](#feature-requests)
  - [Issue Lifecycle](#issue-lifecycle)
- [👥 Community](#-community)
  - [Getting Help](#getting-help)
  - [Code of Conduct](#code-of-conduct)
  - [Recognition](#recognition)

## 🌟 Welcome

### Project Overview

This project implements a fully declarative and modular system configuration using Nix, nix-darwin, and home-manager. We value contributions that enhance reliability, security, and maintainability.

### How to Contribute

You can contribute by:
- 🐛 Reporting and fixing bugs
- ✨ Suggesting and implementing features
- 📚 Improving documentation
- 👁️ Reviewing pull requests
- 💡 Sharing ideas and feedback
- 🤝 Helping other contributors

### First Time? Start Here

1. Read our [Getting Started](#-getting-started) guide
2. Look for issues labeled `good first issue`
3. Join our community discussions
4. Don't hesitate to ask questions!

## 🔍 Contribution Workflow

### 1. Find or Create an Issue

- Browse our [issue tracker](https://github.com/aytordev/system/issues)
- Search for existing issues before creating a new one
- If you find a relevant issue, comment to express interest
- If no issue exists, create one following our [issue guidelines](#-issue-management)

### 2. Set Up Your Environment

1. **Fork the Repository**
   - Click "Fork" at the top-right of the repository page
   - This creates your personal copy of the project

2. **Clone Your Fork**
   ```bash
   git clone git@github.com:YOUR-USERNAME/system.git
   cd system
   ```

3. **Configure Remotes**
   - Add the main repository as 'upstream':
   ```bash
   git remote add upstream git@github.com:aytordev/system.git
   ```
   - Verify remotes are set up correctly:
   ```bash
   git remote -v
   ```

4. **Create a Feature Branch**
   - Always work on a new branch for each feature/fix:
   ```bash
   git checkout -b type/descriptive-name
   ```
   - Branch naming convention:
     - `feat/` for new features
     - `fix/` for bug fixes
     - `docs/` for documentation
     - `refactor/` for code improvements
     - `test/` for test additions

### 3. Make Your Changes

1. **Understand the Scope**
   - Focus on one logical change per PR
   - Keep changes small and reviewable (300-500 lines max per PR)
   - Reference related issues in your commit messages using `#issue-number`

2. **Development Workflow**
   - Make small, atomic commits that focus on a single change
   - Test your changes locally before committing
   - Update documentation alongside code changes
   - Follow our [code style guidelines](CODE_STYLE.md)
   - Run linters and formatters before committing

3. **Testing**
   - Add or update tests for all new functionality
   - Run the full test suite locally before pushing
   - Document any testing limitations or assumptions
   - Ensure all tests pass before opening a PR

4. **Documentation**
   - Update relevant documentation with your changes
   - Add examples for new features or configurations
   - Clearly document any breaking changes
   - Keep README files up to date with usage examples

### 4. Branch Naming and Git Workflow

#### Branch Naming Convention

Create feature branches from the latest `main` branch using the following format:

```
type/description-in-kebab-case
```

**Examples:**
```
feat/add-user-authentication
fix/login-form-validation
docs/update-api-documentation
refactor/user-service
chore/update-dependencies
```

#### Creating a New Branch

```bash
# Make sure you're on the latest main branch
git checkout main
git pull upstream main

# Create and switch to a new branch
git checkout -b type/descriptive-branch-name

# Push the branch to your fork
git push -u origin type/descriptive-branch-name
```

### 5. Commit with Gitmoji

We follow the [Conventional Commits](https://www.conventionalcommits.org/) specification with [Gitmoji](https://gitmoji.dev/) to create meaningful, consistent commit messages. Always use gitmoji codes (e.g., `:sparkles:`) instead of emoji images.

#### Commit Message Structure

```
:gitmoji: type(scope): concise description

[optional body]

[optional footer]
```

**Important:** Always use gitmoji codes (e.g., `:sparkles:`) in your commit messages, not emoji characters. This ensures consistency across different systems and editors.

#### Gitmoji Types and Usage

| Type | Gitmoji Code | When to Use | Example |
|------|--------------|-------------|---------|
| `feat` | `:sparkles:` | New features or significant additions | `:sparkles: feat(auth): add MFA support` |
| `fix` | `:bug:` | Bug fixes | `:bug: fix(api): handle null user edge case` |
| `docs` | `:memo:` | Documentation changes | `:memo: docs: update API reference` |
| `style` | `:art:` | Code style/formatting changes | `:art: style: format with prettier` |
| `refactor` | `:recycle:` | Code changes that neither fix bugs nor add features | `:recycle: refactor(auth): simplify token validation` |
| `perf` | `:zap:` | Performance improvements | `:zap: perf(db): optimize query performance` |
| `test` | `:white_check_mark:` | Adding or modifying tests | `:white_check_mark: test(utils): add test coverage` |
| `chore` | `:wrench:` | Build process or auxiliary tool changes | `:wrench: chore(deps): update dependencies` |
| `ci` | `:construction_worker:` | CI configuration changes | `:construction_worker: ci: add GitHub Actions workflow` |
| `build` | `:package:` | Build system or external dependencies | `:package: build: update webpack config` |
| `revert` | `:rewind:` | Revert previous commit | `:rewind: revert: revert auth changes` |
| `wip` | `:construction:` | Work in progress | `:construction: wip: implement payment flow` |
| `security` | `:lock:` | Security-related changes | `:lock: security: upgrade vulnerable packages` |
| `i18n` | `:globe_with_meridians:` | Internationalization/localization | `:globe_with_meridians: i18n: add Spanish translation` |

#### Commit Message Components

1. **Gitmoji**
   - Always start with an appropriate Gitmoji
   - Use the most specific emoji that matches the change
   - Don't use multiple emojis in a single commit

2. **Type (Required)**
   - Must be one of the standard types listed above
   - Use lowercase
   - Be specific and consistent

3. **Scope (Optional)**
   - Enclosed in parentheses
   - Describes the section of the codebase affected
   - Examples: `(auth)`, `(api)`, `(ui)`, `(config)`
   - Use `*` for changes affecting multiple scopes

4. **Description (Required)**
   - Use imperative, present tense ("add" not "added" or "adds")
   - Don't capitalize the first letter
   - No period at the end
   - Keep it under 72 characters

5. **Body (Optional)**
   - Separate from subject with a blank line
   - Use imperative, present tense
   - Explain what and why, not how
   - Wrap at 72 characters
   - Use bullet points for multiple changes

6. **Footer (Optional)**
   - Separate from body with a blank line
   - Reference issues with keywords (e.g., `Closes #123`)
   - Document breaking changes with `BREAKING CHANGE:`
   - Include migration notes if needed

#### Advanced Examples

**Feature with Body and Footer**
```
✨ feat(auth): add OAuth2 with GitHub

- Implement OAuth2 authentication flow
- Add user model extensions for OAuth
- Update configuration documentation
- Add comprehensive test coverage

Closes #123
Related to #456
```

**Bug Fix with Breaking Change**
```
🐛 fix(api): handle null user sessions

- Add null checks in session middleware
- Update error handling in auth service
- Add test cases for edge cases

BREAKING CHANGE: Session middleware now requires valid user object

Closes #789
```

**Documentation Update**
```
📝 docs: update contribution guidelines

- Add detailed commit message guidelines
- Include Gitmoji reference
- Update code review checklist
- Add examples for common scenarios

Addresses #101
```

**Chore with Multiple Dependencies**
```
🔧 chore(deps): update security packages

- Update express from 4.17.1 to 4.18.2
- Upgrade react and react-dom to 18.2.0
- Update jest and related testing libraries

Resolves security advisory GHSA-xxxx-xxxx-xxxx
```

#### Best Practices

1. **Atomic Commits**
   - Each commit should represent a single logical change
   - Keep changes focused and cohesive
   - Split large features into smaller, reviewable commits

2. **Meaningful Messages**
   - Be clear and descriptive
   - Explain why the change is being made
   - Reference relevant issues or discussions

3. **Consistency**
   - Follow the same format across all commits
   - Use the same terminology
   - Keep the style uniform

4. **Review Before Committing**
   - Stage changes selectively with `git add -p`
   - Review staged changes with `git diff --cached`
   - Write a clear, descriptive message

5. **Interactive Rebase**
   - Clean up your commit history before pushing
   - Squash fixup commits
   - Reorder commits logically
   - Rewrite messages for clarity

#### Common Pitfalls to Avoid

❌ **Vague Messages**
```
❌ git commit -m "fix bug"
✅ git commit -m "🐛 fix(auth): handle null token in middleware"
```

❌ **Multiple Changes in One Commit**
```
❌ feat: add user auth and update styles
✅ feat(auth): implement JWT authentication
✅ style(ui): update login form styles
```

❌ **Inconsistent Formatting**
```
❌ FIX: Login issue
✅ 🐛 fix(login): resolve authentication timeout
```

#### Tools and Automation

1. **Commitizen**
   ```bash
   # Install
   npm install -g commitizen
   
   # Use interactive commit helper
   git cz
   ```

2. **Commitlint**
   - Validates commit messages against conventional format
   - Can be integrated with Husky for pre-commit hooks

3. **Git Hooks**
   - Use `prepare-commit-msg` to suggest emojis
   - Add `commit-msg` hook to validate format
   - Use `pre-push` to run tests

4. **Changelog Generation**
   - `standard-version`: Automate versioning and CHANGELOG generation
   - `semantic-release`: Fully automated package publishing

#### Workflow Integration

### Example Workflows

#### 1. Starting a New Feature

```bash
# Make sure you have the latest changes
git checkout main
git pull upstream main

# Create and switch to a new feature branch
git checkout -b feat/user-profile

# Make your changes
# ...

# Stage changes
git add .

# Commit with a descriptive message using gitmoji code
git commit -m ":sparkles: feat(profile): add user profile page"

# Push to your fork
git push -u origin feat/user-profile
```

#### 2. Fixing a Bug

```bash
# Create a branch for the fix
git checkout -b fix/login-validation

# Make your changes
# ...

git add .
git commit -m ":bug: fix(auth): validate email format on login"

# Push to your fork
git push -u origin fix/login-validation
```

#### 3. Updating Documentation

```bash
git checkout -b docs/update-readme

# Update documentation
# ...

git add .
git commit -m ":memo: docs: update installation instructions"
git push -u origin docs/update-readme
```

### Best Practices

1. **Commit Often, Perfect Later**
   - Make small, focused commits
   - Use `git add -p` to stage changes interactively
   - Squash or fixup commits before opening a PR

2. **Write Good Commit Messages**
   - Use the imperative mood ("Add" not "Added" or "Adds")
   - Keep the subject line under 50 characters
   - Explain what and why, not how
   - Reference issues and PRs in the footer

3. **Before Pushing**
   - Run tests
   - Check for linting errors
   - Review your changes with `git diff --staged`
   - Ensure your branch is up to date with main

4. **Pull Requests**
   - Reference the issue in your PR description
   - Keep PRs focused and reviewable (300-500 lines max)
   - Request reviews from relevant team members
   - Address all review comments before merging

3. **WIP Commits**
   ```bash
   git add .
   git commit -m "🚧 wip: in-progress feature"
   # Later, amend or rebase to clean up
   ```

Remember: Good commit messages are the cornerstone of maintainable code. They help your future self and other contributors understand the history and reasoning behind changes.
   - Use imperative mood ("add" not "added" or "adds")
   - Keep it under 72 characters
   - Reference issues at the end (e.g., `Closes #123`)

2. **Body**
   - Explain what and why, not how
   - Use bullet points for multiple changes
   - Reference any relevant issues or PRs

3. **Footer**
   - Breaking changes should start with `BREAKING CHANGE:`
   - Reference related issues with `Closes #123` or `Fixes #456`

#### Examples

**Feature Addition**
```
✨ feat(auth): implement OAuth2 with GitHub

- Add OAuth2 authentication flow
- Create user model extensions
- Update configuration documentation

Closes #123
```

**Bug Fix**
```
🐛 fix(api): prevent null reference in user service

- Add null checks for user object
- Add test coverage for edge cases
- Update API documentation

Fixes #456
```

**Documentation Update**
```
📝 docs(contributing): add AI guidelines

- Add best practices for AI-assisted contributions
- Include common pitfalls to avoid
- Update code review checklist

Refs #789
```

### 5. Submit a Pull Request

1. Push your changes:
   ```bash
   git push -u origin your-branch-name
   ```
2. Open a [new pull request](https://github.com/aytordev/system/compare)
3. Fill out the PR template completely
4. Reference related issues using `Closes #123` or `Fixes #456`
5. Request reviews from relevant maintainers

### 6. Code Review

- Address all review comments
- Push updates to your branch
- Mark resolved comments as resolved
- Be responsive to feedback
- Keep discussions focused and constructive

### 7. After Approval

- Your PR will be squashed and merged
- The branch will be automatically deleted
- Update your local repository:
  ```bash
  git checkout main
  git pull upstream main
  git branch -d your-branch-name
  ```

## 🤖 AI-Assisted Contributions

We actively encourage the use of AI tools to enhance productivity and code quality. This section provides guidelines for effectively leveraging AI in your contributions.

### When to Use AI

AI tools are particularly helpful for:
- Generating boilerplate code
- Refactoring existing code
- Writing test cases
- Improving documentation
- Debugging and error resolution
- Learning new concepts

### Guidelines for AI Tools

1. **Code Review and Understanding**
   - Always thoroughly review AI-generated code
   - Ensure you understand every line of code before committing
   - Verify alignment with our [coding standards](CODE_STYLE.md)
   - Check for security implications and edge cases

2. **Quality Assurance**
   - AI-generated code must meet our quality standards
   - Include comprehensive tests (unit, integration)
   - Document complex logic and decisions
   - Follow established architectural patterns

3. **Intellectual Responsibility**
   - You are responsible for all code you submit
   - Ensure compliance with open source licenses
   - Be transparent about AI usage if asked
   - Respect intellectual property rights

### AI Best Practices

#### Effective Prompting
- **Be Specific**
  ```
  ❌ "Write a function to sort users"
  ✅ "Write a TypeScript function that sorts an array of User objects by last name, then first name, in ascending order. Include JSDoc comments and type definitions."
  ```

- **Provide Context**
  - Share relevant code snippets
  - Reference our codebase patterns
  - Specify performance requirements

- **Iterative Refinement**
  - Start with high-level requirements
  - Gradually add constraints
  - Request explanations for complex logic

#### Code Quality
- **Refinement**
  - Break down complex solutions
  - Ensure consistent style
  - Add meaningful comments
  - Implement proper error handling

- **Testing**
  - Generate test cases
  - Include edge cases
  - Verify test coverage

#### Documentation
- **Code Documentation**
  - Add JSDoc/TSDoc comments
  - Document assumptions and limitations
  - Include usage examples

- **Project Documentation**
  - Update relevant documentation
  - Add inline comments for complex logic
  - Document any AI-specific considerations

### Common Pitfalls to Avoid

1. **Over-reliance on AI**
   - Don't accept AI output without review
   - Verify all factual claims
   - Test thoroughly

2. **Security Risks**
   - Never paste sensitive information into AI tools
   - Sanitize any code before sharing
   - Review for security vulnerabilities

3. **Quality Issues**
   - Watch for "hallucinated" APIs or libraries
   - Check for outdated practices
   - Ensure consistency with project standards

4. **Legal and Ethical Considerations**
   - Respect licensing requirements
   - Avoid copyright infringement
   - Be mindful of data privacy

### Getting Help

If you're using AI tools and need assistance:
1. Check our [AI Guidelines](docs/AI_GUIDELINES.md)
2. Ask in the community discussions
3. Request a code review with specific questions
4. Document any challenges you encounter

### Tools We Recommend

- **Code Generation**: GitHub Copilot, Codeium
- **Code Review**: Amazon CodeWhisperer, Tabnine
- **Documentation**: ChatGPT, Claude
- **Testing**: Codium, Mutable AI

Remember: AI is a tool to augment your work, not replace critical thinking and understanding. You are responsible for the quality and correctness of any code you submit.

## 📌 Issue Management

### Bug Reports

**Required Information:**
1. **Description**
   - Clear summary of the issue
   - Steps to reproduce
   - Expected vs actual behavior

2. **Environment**
   - System information
   - Software versions
   - Configuration details

3. **Additional Context**
   - Error messages/logs
   - Screenshots if applicable
   - Related issues/PRs

### Feature Requests

**What to Include:**
1. **Problem Statement**
   - Clear description of the problem
   - Why it's important to solve
   - Current workarounds

2. **Proposed Solution**
   - Description of the solution
   - Alternative solutions considered
   - Potential impacts

### Issue Lifecycle

1. **New** - Initial submission
2. **Triaged** - Labeled and prioritized
3. **In Progress** - Assigned and being worked on
4. **Review** - Solution proposed, needs review
5. **Resolved** - Fixed in a specific version
6. **Closed** - Won't fix, duplicate, or not reproducible

## 👥 Community

### Getting Help

1. **Search First**
   - Check the [documentation](README.md)
   - Search [existing issues](https://github.com/aytordev/system/issues)
   - Look through [discussions](https://github.com/aytordev/system/discussions)

2. **Ask for Help**
   - Use the appropriate channel
   - Be specific about your question
   - Include relevant details

### Code of Conduct

We are committed to fostering a welcoming and inclusive community. Please review our [Code of Conduct](CODE_OF_CONDUCT.md) for expected behavior and reporting procedures.

### Recognition

All contributors are recognized in our [Contributors](CONTRIBUTORS.md) file. Your contributions are greatly appreciated!

---

📝 *This document was last updated on June 4, 2025*

💡 *Need help? [Open an issue](https://github.com/aytordev/system/issues/new/choose) or join our [discussions](https://github.com/aytordev/system/discussions) for support.*
