# Swiftees

A TypeScript runtime built in Swift.

## Building

To build the project:

```bash
swift build
```

To run the project:

```bash
swift run swiftees
```

To run tests:

```bash
swift test
```

## Requirements

- Swift 5.9 or later
- Linux or macOS

## CI/CD

The project uses GitHub Actions for continuous integration. On every push and pull request to the `main` branch, the workflow will:

1. Install Swift 5.9
2. Build the project
3. Run the binary
4. Execute tests
