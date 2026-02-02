#!/usr/bin/env python3
"""
Test262 Test Runner for Swiftees

This script runs the tc39/test262 test suite against the swiftees JavaScript runtime.
It clones the test262 repository, runs tests, and reports statistics.
"""

import os
import sys
import json
import subprocess
import argparse
from pathlib import Path
from typing import Dict, List, Tuple
import tempfile

class Test262Runner:
    def __init__(self, swiftees_path: str, test262_path: str, max_tests: int = None):
        self.swiftees_path = swiftees_path
        self.test262_path = test262_path
        self.max_tests = max_tests
        self.results = {
            'passed': 0,
            'failed': 0,
            'skipped': 0,
            'total': 0,
            'failures': []
        }

    def clone_test262(self) -> bool:
        """Clone the test262 repository if it doesn't exist."""
        if os.path.exists(self.test262_path):
            print(f"✓ test262 repository already exists at {self.test262_path}")
            return True

        print(f"Cloning test262 repository to {self.test262_path}...")
        try:
            subprocess.run(
                ['git', 'clone', '--depth', '1',
                 'https://github.com/tc39/test262.git',
                 self.test262_path],
                check=True,
                capture_output=True
            )
            print("✓ Successfully cloned test262 repository")
            return True
        except subprocess.CalledProcessError as e:
            print(f"✗ Failed to clone test262: {e}")
            return False

    def find_test_files(self) -> List[Path]:
        """Find all JavaScript test files in the test262 repository."""
        test_dir = Path(self.test262_path) / 'test'
        if not test_dir.exists():
            print(f"✗ Test directory not found: {test_dir}")
            return []

        # Find all .js files in the test directory
        test_files = list(test_dir.rglob('*.js'))

        # Filter out files in _FIXTURES directories (these are not actual tests)
        test_files = [f for f in test_files if '_FIXTURES' not in str(f)]

        if self.max_tests:
            test_files = test_files[:self.max_tests]

        print(f"Found {len(test_files)} test files")
        return test_files

    def run_test(self, test_file: Path) -> Tuple[bool, str]:
        """
        Run a single test file through swiftees.
        Returns (passed, error_message).
        """
        try:
            # Run swiftees with the test file as input
            result = subprocess.run(
                [self.swiftees_path, str(test_file)],
                capture_output=True,
                timeout=5,  # 5 second timeout per test
                text=True
            )

            # Check if swiftees actually executed JavaScript by looking at the output
            # Current swiftees just loads the file and prints metadata, it doesn't execute
            # We need to see actual test output to consider it a pass

            # If we see "Swiftees: Loaded file" in output, it means the file was read
            # but NOT executed, so this should be a failure
            if "Swiftees: Loaded file" in result.stdout:
                return False, "JavaScript execution not implemented (file loaded but not executed)"

            # If there was a runtime error, that's also a failure
            if result.returncode != 0:
                return False, f"Exit code: {result.returncode}, stderr: {result.stderr[:200]}"

            # If we get here with returncode 0 and no "Loaded file" message,
            # it means JS was actually executed and completed successfully
            # This is a real pass - but won't happen until we implement JS execution
            return True, ""

        except subprocess.TimeoutExpired:
            return False, "Test timeout (>5s)"
        except Exception as e:
            return False, str(e)

    def run_all_tests(self):
        """Run all test262 tests and collect results."""
        test_files = self.find_test_files()

        if not test_files:
            print("✗ No test files found")
            return

        print(f"\nRunning {len(test_files)} tests...\n")

        for i, test_file in enumerate(test_files):
            self.results['total'] += 1

            # Show progress
            if (i + 1) % 100 == 0 or i == 0:
                print(f"Progress: {i + 1}/{len(test_files)} tests...")

            passed, error = self.run_test(test_file)

            if passed:
                self.results['passed'] += 1
            else:
                self.results['failed'] += 1
                # Store first 50 failures for reporting
                if len(self.results['failures']) < 50:
                    relative_path = test_file.relative_to(self.test262_path)
                    self.results['failures'].append({
                        'test': str(relative_path),
                        'error': error
                    })

    def print_results(self):
        """Print test results in a formatted way."""
        total = self.results['total']
        passed = self.results['passed']
        failed = self.results['failed']

        if total == 0:
            print("\n✗ No tests were run")
            return

        pass_rate = (passed / total) * 100

        print("\n" + "="*60)
        print("TEST262 RESULTS")
        print("="*60)
        print(f"Total tests:   {total}")
        print(f"Passed:        {passed} ({pass_rate:.2f}%)")
        print(f"Failed:        {failed} ({(100-pass_rate):.2f}%)")
        print("="*60)

        if self.results['failures']:
            print(f"\nFirst {len(self.results['failures'])} failures:")
            for failure in self.results['failures'][:10]:
                print(f"  • {failure['test']}")
                if failure['error']:
                    print(f"    Error: {failure['error']}")

        print("\n")

    def save_results_json(self, output_file: str):
        """Save results to a JSON file."""
        with open(output_file, 'w') as f:
            json.dump(self.results, f, indent=2)
        print(f"✓ Results saved to {output_file}")

    def generate_pr_comment(self) -> str:
        """Generate a markdown comment for GitHub PR."""
        total = self.results['total']
        passed = self.results['passed']
        failed = self.results['failed']

        if total == 0:
            return "## Test262 Results\n\n⚠️ No tests were run."

        pass_rate = (passed / total) * 100

        # Choose emoji based on pass rate
        if pass_rate >= 90:
            emoji = "🎉"
        elif pass_rate >= 50:
            emoji = "📊"
        else:
            emoji = "🔧"

        comment = f"""## {emoji} Test262 Results

| Metric | Value |
|--------|-------|
| **Total Tests** | {total} |
| **Passed** | {passed} ({pass_rate:.2f}%) |
| **Failed** | {failed} ({(100-pass_rate):.2f}%) |

"""

        if pass_rate < 100 and self.results['failures']:
            comment += f"\n### Sample Failures (first 5)\n\n"
            for failure in self.results['failures'][:5]:
                comment += f"- `{failure['test']}`\n"

        comment += "\n---\n*This test suite is expected to have failures as swiftees is under active development.*"

        return comment

def main():
    parser = argparse.ArgumentParser(description='Run test262 suite against swiftees')
    parser.add_argument('--swiftees', required=True, help='Path to swiftees executable')
    parser.add_argument('--test262-dir', default='test262', help='Path to test262 directory')
    parser.add_argument('--max-tests', type=int, help='Maximum number of tests to run')
    parser.add_argument('--output', default='test262-results.json', help='Output JSON file')
    parser.add_argument('--pr-comment', help='Output file for PR comment markdown')

    args = parser.parse_args()

    # Verify swiftees exists
    if not os.path.exists(args.swiftees):
        print(f"✗ swiftees executable not found: {args.swiftees}")
        sys.exit(1)

    runner = Test262Runner(args.swiftees, args.test262_dir, args.max_tests)

    # Clone test262 if needed
    if not runner.clone_test262():
        sys.exit(1)

    # Run tests
    runner.run_all_tests()

    # Print and save results
    runner.print_results()
    runner.save_results_json(args.output)

    # Generate PR comment if requested
    if args.pr_comment:
        comment = runner.generate_pr_comment()
        with open(args.pr_comment, 'w') as f:
            f.write(comment)
        print(f"✓ PR comment saved to {args.pr_comment}")

    # Exit with success even if tests failed (CI should be allowed to fail)
    sys.exit(0)

if __name__ == '__main__':
    main()
