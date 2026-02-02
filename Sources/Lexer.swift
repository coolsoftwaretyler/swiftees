import Foundation

// Token types for TypeScript/JavaScript
enum TokenType: String, Equatable {
    // Literals
    case identifier
    case stringLiteral
    case numericLiteral
    case booleanLiteral
    case nullLiteral
    case undefinedLiteral
    case templateLiteral
    case regexLiteral

    // Keywords
    case `break`
    case `case`
    case `catch`
    case `class`
    case `const`
    case `continue`
    case `debugger`
    case `default`
    case `delete`
    case `do`
    case `else`
    case `export`
    case `extends`
    case `finally`
    case `for`
    case `function`
    case `if`
    case `import`
    case `in`
    case `instanceof`
    case `let`
    case `new`
    case `return`
    case `super`
    case `switch`
    case `this`
    case `throw`
    case `try`
    case `typeof`
    case `var`
    case `void`
    case `while`
    case `with`
    case `yield`

    // TypeScript-specific keywords
    case `as`
    case `async`
    case `await`
    case `declare`
    case `enum`
    case `implements`
    case `interface`
    case `namespace`
    case `private`
    case `protected`
    case `public`
    case `readonly`
    case `static`
    case `type`

    // Operators
    case plus
    case minus
    case star
    case slash
    case percent
    case starStar
    case equals
    case plusEquals
    case minusEquals
    case starEquals
    case slashEquals
    case percentEquals
    case starStarEquals
    case equalEqual
    case equalEqualEqual
    case bangEqual
    case bangEqualEqual
    case lessThan
    case greaterThan
    case lessThanEqual
    case greaterThanEqual
    case ampersand
    case pipe
    case caret
    case tilde
    case ampersandAmpersand
    case pipePipe
    case bang
    case question
    case questionQuestion
    case questionDot
    case plusPlus
    case minusMinus
    case lessThanLessThan
    case greaterThanGreaterThan
    case greaterThanGreaterThanGreaterThan
    case ampersandEquals
    case pipeEquals
    case caretEquals
    case lessThanLessThanEquals
    case greaterThanGreaterThanEquals
    case greaterThanGreaterThanGreaterThanEquals
    case arrow

    // Punctuation
    case openParen
    case closeParen
    case openBrace
    case closeBrace
    case openBracket
    case closeBracket
    case semicolon
    case comma
    case dot
    case colon
    case ellipsis

    // Special
    case eof
    case whitespace
    case newline
    case comment
    case unknown
}

// Token structure
struct Token: Equatable {
    let type: TokenType
    let lexeme: String
    let line: Int
    let column: Int

    init(type: TokenType, lexeme: String, line: Int, column: Int) {
        self.type = type
        self.lexeme = lexeme
        self.line = line
        self.column = column
    }
}

// Lexer class
class Lexer {
    private let source: String
    private var current: String.Index
    private var line: Int = 1
    private var column: Int = 1

    init(source: String) {
        self.source = source
        self.current = source.startIndex
    }

    func tokenize() throws -> [Token] {
        // TODO: Implement tokenization
        // This is a placeholder that will be implemented later
        return []
    }

    private func peek() -> Character? {
        guard current < source.endIndex else { return nil }
        return source[current]
    }

    private func advance() -> Character? {
        guard current < source.endIndex else { return nil }
        let char = source[current]
        current = source.index(after: current)
        column += 1
        return char
    }

    private func isAtEnd() -> Bool {
        return current >= source.endIndex
    }
}
