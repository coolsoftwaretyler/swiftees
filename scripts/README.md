# Test262 Integration

This directory contains scripts for running the [tc39/test262](https://github.com/tc39/test262) ECMAScript test suite against the swiftees JavaScript runtime.

## Test Runner Script

### `run_test262.py`

A Python script that:
1. Clones the test262 repository (if not already present)
2. Discovers all test files
3. Runs each test through the swiftees executable
4. Collects pass/fail statistics
5. Generates reports and PR comments

### Usage

```bash
# Build swiftees first
swift build -c release

# Run the test suite
python3 scripts/run_test262.py \
  --swiftees .build/release/swiftees \
  --test262-dir test262 \
  --max-tests 100 \
  --output results.json \
  --pr-comment comment.md
```

### Options

- `--swiftees`: Path to the swiftees executable (required)
- `--test262-dir`: Directory where test262 will be cloned (default: `test262`)
- `--max-tests`: Limit the number of tests to run (useful for CI)
- `--output`: JSON file for detailed results (default: `test262-results.json`)
- `--pr-comment`: Markdown file for GitHub PR comments

## GitHub Actions Integration

The `.github/workflows/test262.yml` workflow automatically:
- Runs on every pull request
- Builds swiftees from source
- Executes a sample of test262 tests (100 tests by default)
- Comments on the PR with pass/fail statistics
- Uploads test results as artifacts

The workflow is configured with `continue-on-error: true`, so test failures won't block PRs.

## Current Status

Swiftees is in early development and does not yet execute JavaScript code. The current implementation:
- Accepts a file path as a command line argument
- Reads the file contents
- Exits successfully (causing all tests to "pass" until JS execution is implemented)

As JavaScript execution capabilities are added to swiftees, the test262 suite will provide comprehensive validation of ECMAScript compliance.
