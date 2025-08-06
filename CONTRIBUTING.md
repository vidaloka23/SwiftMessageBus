# Contributing to SwiftMessageBus

## Commit Message Guidelines

This project follows [Conventional Commits 1.0.0](https://www.conventionalcommits.org/en/v1.0.0/) specification for all commit messages.

### Commit Message Format

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Types

Must be one of the following:

- **feat**: A new feature
- **fix**: A bug fix  
- **docs**: Documentation only changes
- **style**: Changes that don't affect code meaning (formatting, missing semicolons, etc)
- **refactor**: Code change that neither fixes a bug nor adds a feature
- **perf**: Code change that improves performance
- **test**: Adding missing tests or correcting existing tests
- **build**: Changes that affect the build system or external dependencies
- **ci**: Changes to CI configuration files and scripts
- **chore**: Other changes that don't modify src or test files
- **revert**: Reverts a previous commit

### Scope

The scope should be the name of the package/module affected:

- **core**: Core message bus functionality
- **macros**: Swift macro implementations
- **plugins**: Plugin system
- **routing**: Layer-based routing
- **tests**: Test infrastructure
- **bench**: Benchmarks
- **docs**: Documentation
- **deps**: Dependencies

### Subject

- Use the imperative, present tense: "change" not "changed" nor "changes"
- Don't capitalize the first letter
- No period (.) at the end

### Breaking Changes

Breaking changes must be indicated:

1. By appending `!` after type/scope: `feat(api)!: change handler signature`
2. By adding `BREAKING CHANGE:` in the footer

### Examples

```bash
# Feature
feat(core): add query caching with TTL support

# Bug fix
fix(routing): prevent invalid layer transitions

# Breaking change
feat(api)!: change event handler to async/await

BREAKING CHANGE: Event handlers must now be async functions

# Documentation
docs: add plugin development guide

# Performance
perf(core): optimize message queue with ring buffer

# With scope and body
fix(routing): handle nil destination in layer validation

Previously, messages with nil destinations would cause
a crash when validating layer routing rules. This fix
properly handles nil destinations as broadcast messages.

Fixes #123
```

## Setting Up Git Commit Template

To use the project's commit template:

```bash
git config --local commit.template .gitmessage
```

## Pull Request Process

1. Ensure all commits follow the Conventional Commits specification
2. Update the README.md with details of changes if applicable
3. Increase version numbers following [Semantic Versioning](https://semver.org/)
4. The PR will be merged once approved by maintainers

## Automated Changelog

The changelog is automatically generated from commit messages using the GitHub Action workflow. Ensure your commits follow the convention for proper categorization in the changelog.