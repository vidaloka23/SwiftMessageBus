# Story 1.4: Setup CI/CD Pipeline

**Status**: Draft
**Epic**: 1 - Core Foundation and Package Setup
**Priority**: P0 - Critical
**Estimated Points**: 5
**Dependencies**: Story 1.1 (Package structure)

## Story

**As a** maintainer  
**I want** automated testing and validation  
**So that** code quality remains high

## Acceptance Criteria

- [ ] GitHub Actions workflow configured for CI/CD
- [ ] Multi-platform testing (Ubuntu latest, macOS 13, macOS 14)
- [ ] Multiple Swift version testing (5.9, 5.10)
- [ ] Code coverage reporting integrated
- [ ] SwiftLint validation running
- [ ] Automated release process configured
- [ ] Performance benchmarks run on commits
- [ ] Build status badge in README

## Dev Notes

### CI/CD Strategy
- Use GitHub Actions for all automation
- Matrix testing for platforms and Swift versions
- Fail fast on any test failure
- Cache dependencies for faster builds
- Run benchmarks only on macOS (Swift Benchmark requirement)

### Workflow Triggers
- Push to main and develop branches
- Pull requests to main
- Release tag creation
- Manual workflow dispatch

## Tasks

### Development Tasks
- [ ] Create .github/workflows/ directory structure
- [ ] Implement ci.yml workflow file
- [ ] Configure SwiftLint with .swiftlint.yml
- [ ] Set up swift-format configuration
- [ ] Configure code coverage with codecov
- [ ] Add release automation workflow
- [ ] Add build status badges to README

### CI Workflow Implementation

#### .github/workflows/ci.yml
```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]
  release:
    types: [created]

jobs:
  test:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: [ubuntu-latest, macos-13, macos-14]
        swift: ['5.9', '5.10']
    steps:
      - uses: actions/checkout@v4
      
      - uses: swift-actions/setup-swift@v1
        with:
          swift-version: ${{ matrix.swift }}
      
      - name: Cache Swift packages
        uses: actions/cache@v3
        with:
          path: .build
          key: ${{ runner.os }}-swift-${{ matrix.swift }}-${{ hashFiles('Package.resolved') }}
          restore-keys: |
            ${{ runner.os }}-swift-${{ matrix.swift }}-
      
      - name: Build
        run: swift build -v
      
      - name: Run tests
        run: swift test -v --enable-code-coverage
      
      - name: Generate coverage report
        if: matrix.os == 'ubuntu-latest' && matrix.swift == '5.10'
        run: |
          swift test --enable-code-coverage
          xcrun llvm-cov export -format="lcov" \
            .build/debug/SwiftMessageBusPackageTests.xctest \
            -instr-profile .build/debug/codecov/default.profdata > coverage.lcov
      
      - name: Upload coverage
        if: matrix.os == 'ubuntu-latest' && matrix.swift == '5.10'
        uses: codecov/codecov-action@v3
        with:
          file: ./coverage.lcov
          fail_ci_if_error: true

  benchmarks:
    runs-on: macos-14
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v4
      
      - uses: swift-actions/setup-swift@v1
        with:
          swift-version: '5.10'
      
      - name: Run benchmarks
        run: |
          swift build -c release --target MessageBusBenchmarks
          swift run -c release MessageBusBenchmarks
      
      - name: Validate performance targets
        run: |
          # Parse benchmark output and validate
          # Fail if <100K msgs/sec or >1ms p99 latency
          echo "Performance validation placeholder"

  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: SwiftLint
        uses: norio-nomura/action-swiftlint@3.2.1
        with:
          args: --strict
      
      - name: Format check
        run: |
          brew install swift-format
          swift-format lint --recursive Sources Tests

  documentation:
    runs-on: macos-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v4
      
      - name: Generate docs
        run: |
          swift package generate-documentation \
            --target SwiftMessageBus \
            --output-path ./docs/api
      
      - name: Deploy to GitHub Pages
        uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./docs/api

  release:
    needs: [test, lint]
    if: github.event_name == 'release'
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Build release
        run: swift build -c release
      
      - name: Create release archive
        run: |
          zip -r SwiftMessageBus.zip .build/release/SwiftMessageBus
      
      - name: Upload release asset
        uses: actions/upload-release-asset@v1
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          upload_url: ${{ github.event.release.upload_url }}
          asset_path: ./SwiftMessageBus.zip
          asset_name: SwiftMessageBus-${{ github.event.release.tag_name }}.zip
          asset_content_type: application/zip
```

#### .swiftlint.yml
```yaml
included:
  - Sources
  - Tests
  - Benchmarks

excluded:
  - .build
  - Package.swift

opt_in_rules:
  - empty_count
  - empty_string
  - closure_end_indentation
  - closure_spacing
  - collection_alignment
  - contains_over_filter_count
  - explicit_init
  - fatal_error_message
  - first_where
  - force_unwrapping
  - implicitly_unwrapped_optional
  - last_where
  - literal_expression_end_indentation
  - multiline_arguments
  - multiline_function_chains
  - multiline_literal_brackets
  - multiline_parameters
  - multiline_parameters_brackets
  - operator_usage_whitespace
  - overridden_super_call
  - pattern_matching_keywords
  - prefer_self_type_over_type_of_self
  - redundant_nil_coalescing
  - redundant_type_annotation
  - sorted_first_last
  - trailing_closure
  - unneeded_parentheses_in_closure_argument
  - vertical_whitespace_closing_braces
  - vertical_whitespace_opening_braces
  - yoda_condition

line_length: 120
file_length:
  warning: 500
  error: 1000
type_body_length:
  warning: 300
  error: 500
```

### Testing Tasks
- [ ] Verify workflow syntax with act or GitHub UI
- [ ] Test multi-platform matrix
- [ ] Verify SwiftLint catches violations
- [ ] Test code coverage reporting
- [ ] Verify benchmark execution
- [ ] Test release workflow with tag

## Definition of Done

- [ ] CI workflow runs on all triggers
- [ ] All matrix combinations pass
- [ ] Code coverage reporting works
- [ ] SwiftLint integrated and passing
- [ ] Benchmarks run without errors
- [ ] Documentation generation works
- [ ] Release automation tested
- [ ] Build badges added to README

## Dev Agent Record

### Agent Model Used
- 

### Debug Log References
- 

### Completion Notes
- 

### File List
- [ ] .github/workflows/ci.yml
- [ ] .github/workflows/release.yml (if separate)
- [ ] .swiftlint.yml
- [ ] .swift-format (configuration file)
- [ ] Updates to README.md (badges)

### Change Log
- 