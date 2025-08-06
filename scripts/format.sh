#!/bin/bash

# Swift Formatting Script
# Runs swift-format and SwiftLint to ensure code follows Google's Swift Style Guide

set -e

echo "🔧 Running Swift formatters..."

# Check if swift-format is installed
if ! command -v swift-format &> /dev/null; then
    echo "⚠️  swift-format is not installed."
    echo "   Install with: brew install swift-format"
    echo "   Or: git clone https://github.com/apple/swift-format.git && cd swift-format && swift build -c release"
    exit 1
fi

# Check if swiftlint is installed
if ! command -v swiftlint &> /dev/null; then
    echo "⚠️  SwiftLint is not installed."
    echo "   Install with: brew install swiftlint"
    exit 1
fi

# Get the script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

cd "$PROJECT_ROOT"

# Run swift-format
echo "📝 Running swift-format..."
if [ "$1" == "--fix" ]; then
    echo "   Fixing format issues..."
    swift-format -i -r Sources/ Tests/ Benchmarks/ --configuration .swift-format
    echo "   ✅ Format issues fixed"
else
    echo "   Checking format..."
    if swift-format lint -r Sources/ Tests/ Benchmarks/ --configuration .swift-format; then
        echo "   ✅ No format issues found"
    else
        echo "   ❌ Format issues found. Run '$0 --fix' to fix them."
        exit 1
    fi
fi

# Run SwiftLint
echo "📏 Running SwiftLint..."
if [ "$1" == "--fix" ]; then
    echo "   Auto-correcting issues..."
    swiftlint --fix --config .swiftlint.yml
    echo "   ✅ Auto-corrections applied"
fi

# Always run lint check to show remaining issues
if swiftlint lint --config .swiftlint.yml --quiet; then
    echo "   ✅ No linting issues found"
else
    echo "   ⚠️  Some linting issues remain"
fi

echo "✨ Formatting complete!"
