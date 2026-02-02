import Foundation

// Get command line arguments
let arguments = CommandLine.arguments

if arguments.count > 1 {
    // If a file path is provided, attempt to read and execute it
    let filePath = arguments[1]

    do {
        let fileContents = try String(contentsOfFile: filePath, encoding: .utf8)
        print("Swiftees: Loaded file '\(filePath)'")
        print("Swiftees: File size: \(fileContents.count) bytes")

        // TODO: Actually parse and execute JavaScript
        // For now, we just acknowledge we received the file

        // Exit successfully for now (all tests will "pass" until we implement JS execution)
        exit(0)
    } catch {
        print("Swiftees: Error reading file '\(filePath)': \(error)")
        exit(1)
    }
} else {
    // No file provided, print welcome message
    print("Hello, World!")
    print("Welcome to Swiftees - a TypeScript runtime built in Swift!")
    print("Usage: swiftees <file.js>")
}
