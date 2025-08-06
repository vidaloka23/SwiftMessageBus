# SwiftMessageBus Makefile
# Commands for common development tasks

.PHONY: help
help: ## Show this help message
	@echo "SwiftMessageBus Development Commands"
	@echo "===================================="
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

.PHONY: build
build: ## Build the package
	swift build

.PHONY: test
test: ## Run tests
	swift test

.PHONY: test-coverage
test-coverage: ## Run tests with coverage
	swift test --enable-code-coverage
	@echo "Coverage report generated. Use 'make show-coverage' to view."

.PHONY: show-coverage
show-coverage: ## Show test coverage report
	xcrun llvm-cov report \
		.build/debug/SwiftMessageBusPackageTests.xctest/Contents/MacOS/SwiftMessageBusPackageTests \
		--instr-profile=.build/debug/codecov/default.profdata \
		--ignore-filename-regex=".build|Tests"

.PHONY: clean
clean: ## Clean build artifacts
	swift package clean
	rm -rf .build

.PHONY: format
format: ## Format code using swift-format and SwiftLint
	./scripts/format.sh --fix

.PHONY: lint
lint: ## Check code formatting without fixing
	./scripts/format.sh

.PHONY: install-tools
install-tools: ## Install required development tools
	@echo "Installing SwiftLint..."
	@brew list swiftlint &>/dev/null || brew install swiftlint
	@echo "Installing swift-format..."
	@brew list swift-format &>/dev/null || brew install swift-format
	@echo "✅ All tools installed"

.PHONY: benchmark
benchmark: ## Run performance benchmarks
	swift build -c release --target MessageBusBenchmarks
	.build/release/MessageBusBenchmarks

.PHONY: docs
docs: ## Generate documentation
	swift package generate-documentation

.PHONY: open-docs
open-docs: docs ## Generate and open documentation
	open .build/documentation/swiftmessagebus/index.html

.PHONY: release
release: lint test ## Prepare for release (lint, test)
	@echo "✅ Ready for release"

.PHONY: update-deps
update-deps: ## Update package dependencies
	swift package update

.PHONY: resolve-deps
resolve-deps: ## Resolve package dependencies
	swift package resolve

.PHONY: xcode
xcode: ## Generate and open Xcode project
	swift package generate-xcodeproj
	open *.xcodeproj

.PHONY: ci
ci: lint test ## Run CI tasks locally
	@echo "✅ CI checks passed"
