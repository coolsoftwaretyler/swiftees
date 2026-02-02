import XCTest
@testable import Swiftees

final class LexerTests: XCTestCase {

    // MARK: - Basic Literals

    func testNumericLiterals() throws {
        // Integers
        try assertTokens("42", [.numericLiteral])
        try assertTokens("0", [.numericLiteral])
        try assertTokens("123456789", [.numericLiteral])

        // Decimals
        try assertTokens("3.14", [.numericLiteral])
        try assertTokens("0.5", [.numericLiteral])
        try assertTokens(".5", [.numericLiteral])

        // Scientific notation
        try assertTokens("1e10", [.numericLiteral])
        try assertTokens("1e-10", [.numericLiteral])
        try assertTokens("1.5e10", [.numericLiteral])

        // Hex
        try assertTokens("0xFF", [.numericLiteral])
        try assertTokens("0xDEADBEEF", [.numericLiteral])

        // Binary
        try assertTokens("0b1010", [.numericLiteral])

        // Octal
        try assertTokens("0o755", [.numericLiteral])

        // With underscores (ES2021)
        try assertTokens("1_000_000", [.numericLiteral])
        try assertTokens("0xFF_FF", [.numericLiteral])
    }

    func testStringLiterals() throws {
        // Double quotes
        try assertTokens("\"hello\"", [.stringLiteral])
        try assertTokens("\"hello world\"", [.stringLiteral])
        try assertTokens("\"\"", [.stringLiteral])

        // Single quotes
        try assertTokens("'hello'", [.stringLiteral])
        try assertTokens("'hello world'", [.stringLiteral])
        try assertTokens("''", [.stringLiteral])

        // Escape sequences
        try assertTokens("\"hello\\nworld\"", [.stringLiteral])
        try assertTokens("\"tab\\there\"", [.stringLiteral])
        try assertTokens("\"quote\\\"here\"", [.stringLiteral])
        try assertTokens("'it\\'s'", [.stringLiteral])

        // Unicode escapes
        try assertTokens("\"\\u0041\"", [.stringLiteral])
        try assertTokens("\"\\u{1F600}\"", [.stringLiteral])
    }

    func testTemplateLiterals() throws {
        // Basic template
        try assertTokens("`hello`", [.templateLiteral])
        try assertTokens("`hello world`", [.templateLiteral])
        try assertTokens("``", [.templateLiteral])

        // With expressions (complex tokenization)
        try assertTokens("`hello ${name}`", [.templateLiteral])
        try assertTokens("`${x} + ${y} = ${x + y}`", [.templateLiteral])

        // Multiline
        try assertTokens("`line1\nline2`", [.templateLiteral])
    }

    func testBooleanLiterals() throws {
        try assertTokens("true", [.booleanLiteral])
        try assertTokens("false", [.booleanLiteral])
    }

    func testNullAndUndefined() throws {
        try assertTokens("null", [.nullLiteral])
        try assertTokens("undefined", [.undefinedLiteral])
    }

    func testRegexLiterals() throws {
        try assertTokens("/test/", [.regexLiteral])
        try assertTokens("/test/g", [.regexLiteral])
        try assertTokens("/test/gi", [.regexLiteral])
        try assertTokens("/[a-z]+/i", [.regexLiteral])
        try assertTokens("/\\d{3}-\\d{4}/", [.regexLiteral])
    }

    // MARK: - Identifiers

    func testIdentifiers() throws {
        try assertTokens("x", [.identifier])
        try assertTokens("myVar", [.identifier])
        try assertTokens("_private", [.identifier])
        try assertTokens("$jquery", [.identifier])
        try assertTokens("camelCase", [.identifier])
        try assertTokens("PascalCase", [.identifier])
        try assertTokens("snake_case", [.identifier])
        try assertTokens("CONSTANT_CASE", [.identifier])
        try assertTokens("var123", [.identifier])

        // Unicode identifiers
        try assertTokens("café", [.identifier])
        try assertTokens("日本語", [.identifier])
    }

    // MARK: - Keywords

    func testJavaScriptKeywords() throws {
        let keywords: [(String, TokenType)] = [
            ("break", .break),
            ("case", .case),
            ("catch", .catch),
            ("class", .class),
            ("const", .const),
            ("continue", .continue),
            ("debugger", .debugger),
            ("default", .default),
            ("delete", .delete),
            ("do", .do),
            ("else", .else),
            ("export", .export),
            ("extends", .extends),
            ("finally", .finally),
            ("for", .for),
            ("function", .function),
            ("if", .if),
            ("import", .import),
            ("in", .in),
            ("instanceof", .instanceof),
            ("let", .let),
            ("new", .new),
            ("return", .return),
            ("super", .super),
            ("switch", .switch),
            ("this", .this),
            ("throw", .throw),
            ("try", .try),
            ("typeof", .typeof),
            ("var", .var),
            ("void", .void),
            ("while", .while),
            ("with", .with),
            ("yield", .yield),
        ]

        for (keyword, expectedType) in keywords {
            try assertTokens(keyword, [expectedType])
        }
    }

    func testTypeScriptKeywords() throws {
        let keywords: [(String, TokenType)] = [
            ("as", .as),
            ("async", .async),
            ("await", .await),
            ("declare", .declare),
            ("enum", .enum),
            ("implements", .implements),
            ("interface", .interface),
            ("namespace", .namespace),
            ("private", .private),
            ("protected", .protected),
            ("public", .public),
            ("readonly", .readonly),
            ("static", .static),
            ("type", .type),
        ]

        for (keyword, expectedType) in keywords {
            try assertTokens(keyword, [expectedType])
        }
    }

    // MARK: - Operators

    func testArithmeticOperators() throws {
        try assertTokens("+", [.plus])
        try assertTokens("-", [.minus])
        try assertTokens("*", [.star])
        try assertTokens("/", [.slash])
        try assertTokens("%", [.percent])
        try assertTokens("**", [.starStar])
    }

    func testComparisonOperators() throws {
        try assertTokens("==", [.equalEqual])
        try assertTokens("===", [.equalEqualEqual])
        try assertTokens("!=", [.bangEqual])
        try assertTokens("!==", [.bangEqualEqual])
        try assertTokens("<", [.lessThan])
        try assertTokens(">", [.greaterThan])
        try assertTokens("<=", [.lessThanEqual])
        try assertTokens(">=", [.greaterThanEqual])
    }

    func testLogicalOperators() throws {
        try assertTokens("&&", [.ampersandAmpersand])
        try assertTokens("||", [.pipePipe])
        try assertTokens("!", [.bang])
    }

    func testBitwiseOperators() throws {
        try assertTokens("&", [.ampersand])
        try assertTokens("|", [.pipe])
        try assertTokens("^", [.caret])
        try assertTokens("~", [.tilde])
        try assertTokens("<<", [.lessThanLessThan])
        try assertTokens(">>", [.greaterThanGreaterThan])
        try assertTokens(">>>", [.greaterThanGreaterThanGreaterThan])
    }

    func testAssignmentOperators() throws {
        try assertTokens("=", [.equals])
        try assertTokens("+=", [.plusEquals])
        try assertTokens("-=", [.minusEquals])
        try assertTokens("*=", [.starEquals])
        try assertTokens("/=", [.slashEquals])
        try assertTokens("%=", [.percentEquals])
        try assertTokens("**=", [.starStarEquals])
        try assertTokens("&=", [.ampersandEquals])
        try assertTokens("|=", [.pipeEquals])
        try assertTokens("^=", [.caretEquals])
        try assertTokens("<<=", [.lessThanLessThanEquals])
        try assertTokens(">>=", [.greaterThanGreaterThanEquals])
        try assertTokens(">>>=", [.greaterThanGreaterThanGreaterThanEquals])
    }

    func testOtherOperators() throws {
        try assertTokens("++", [.plusPlus])
        try assertTokens("--", [.minusMinus])
        try assertTokens("?", [.question])
        try assertTokens("??", [.questionQuestion])
        try assertTokens("?.", [.questionDot])
        try assertTokens("=>", [.arrow])
    }

    // MARK: - Punctuation

    func testPunctuation() throws {
        try assertTokens("(", [.openParen])
        try assertTokens(")", [.closeParen])
        try assertTokens("{", [.openBrace])
        try assertTokens("}", [.closeBrace])
        try assertTokens("[", [.openBracket])
        try assertTokens("]", [.closeBracket])
        try assertTokens(";", [.semicolon])
        try assertTokens(",", [.comma])
        try assertTokens(".", [.dot])
        try assertTokens(":", [.colon])
        try assertTokens("...", [.ellipsis])
    }

    // MARK: - Comments

    func testSingleLineComments() throws {
        try assertTokens("// comment", [.comment])
        try assertTokens("//", [.comment])
        try assertTokens("// comment with symbols !@#$%", [.comment])
    }

    func testMultiLineComments() throws {
        try assertTokens("/* comment */", [.comment])
        try assertTokens("/**/", [.comment])
        try assertTokens("/* multi\nline\ncomment */", [.comment])
        try assertTokens("/* comment with */ symbols */", [.comment])
    }

    // MARK: - Whitespace

    func testWhitespace() throws {
        try assertTokens(" ", [.whitespace])
        try assertTokens("   ", [.whitespace])
        try assertTokens("\t", [.whitespace])
        try assertTokens("\t\t", [.whitespace])
    }

    func testNewlines() throws {
        try assertTokens("\n", [.newline])
        try assertTokens("\r\n", [.newline])
        try assertTokens("\r", [.newline])
    }

    // MARK: - Complex Expressions

    func testSimpleExpression() throws {
        try assertTokens("x + y", [.identifier, .whitespace, .plus, .whitespace, .identifier])
    }

    func testVariableDeclaration() throws {
        try assertTokens("const x = 42;", [
            .const, .whitespace, .identifier, .whitespace,
            .equals, .whitespace, .numericLiteral, .semicolon
        ])
    }

    func testFunctionDeclaration() throws {
        try assertTokens("function add(a, b) { return a + b; }", [
            .function, .whitespace, .identifier, .openParen, .identifier, .comma,
            .whitespace, .identifier, .closeParen, .whitespace, .openBrace,
            .whitespace, .return, .whitespace, .identifier, .whitespace, .plus,
            .whitespace, .identifier, .semicolon, .whitespace, .closeBrace
        ])
    }

    func testArrowFunction() throws {
        try assertTokens("(x) => x * 2", [
            .openParen, .identifier, .closeParen, .whitespace, .arrow, .whitespace,
            .identifier, .whitespace, .star, .whitespace, .numericLiteral
        ])
    }

    func testClassDeclaration() throws {
        try assertTokens("class Person { constructor(name) { this.name = name; } }", [
            .class, .whitespace, .identifier, .whitespace, .openBrace, .whitespace,
            .identifier, .openParen, .identifier, .closeParen, .whitespace,
            .openBrace, .whitespace, .this, .dot, .identifier, .whitespace,
            .equals, .whitespace, .identifier, .semicolon, .whitespace,
            .closeBrace, .whitespace, .closeBrace
        ])
    }

    func testTypeScriptTypeAnnotation() throws {
        try assertTokens("let x: number = 5;", [
            .let, .whitespace, .identifier, .colon, .whitespace, .identifier,
            .whitespace, .equals, .whitespace, .numericLiteral, .semicolon
        ])
    }

    func testTypeScriptInterface() throws {
        try assertTokens("interface User { name: string; age: number; }", [
            .interface, .whitespace, .identifier, .whitespace, .openBrace,
            .whitespace, .identifier, .colon, .whitespace, .identifier,
            .semicolon, .whitespace, .identifier, .colon, .whitespace,
            .identifier, .semicolon, .whitespace, .closeBrace
        ])
    }

    func testAsyncAwait() throws {
        try assertTokens("async function fetch() { await getData(); }", [
            .async, .whitespace, .function, .whitespace, .identifier,
            .openParen, .closeParen, .whitespace, .openBrace, .whitespace,
            .await, .whitespace, .identifier, .openParen, .closeParen,
            .semicolon, .whitespace, .closeBrace
        ])
    }

    func testOptionalChaining() throws {
        try assertTokens("obj?.prop", [
            .identifier, .questionDot, .identifier
        ])
    }

    func testNullishCoalescing() throws {
        try assertTokens("x ?? 0", [
            .identifier, .whitespace, .questionQuestion, .whitespace, .numericLiteral
        ])
    }

    func testSpreadOperator() throws {
        try assertTokens("...args", [
            .ellipsis, .identifier
        ])
    }

    func testDestructuring() throws {
        try assertTokens("const { x, y } = obj;", [
            .const, .whitespace, .openBrace, .whitespace, .identifier,
            .comma, .whitespace, .identifier, .whitespace, .closeBrace,
            .whitespace, .equals, .whitespace, .identifier, .semicolon
        ])
    }

    // MARK: - Edge Cases

    func testEmptyString() throws {
        let tokens = try tokenize("")
        XCTAssertEqual(tokens.count, 1, "Should contain EOF token")
        if tokens.count > 0 {
            XCTAssertEqual(tokens[0].type, .eof)
        }
    }

    func testOnlyWhitespace() throws {
        try assertTokens("   \t\n  ", [.whitespace, .whitespace, .newline, .whitespace])
    }

    func testMixedOperators() throws {
        try assertTokens("++x--", [.plusPlus, .identifier, .minusMinus])
    }

    func testOperatorAmbiguity() throws {
        // Test that >> is recognized, not > >
        try assertTokens("x>>y", [.identifier, .greaterThanGreaterThan, .identifier])

        // Test that >>> is recognized
        try assertTokens("x>>>y", [.identifier, .greaterThanGreaterThanGreaterThan, .identifier])
    }

    func testCommentsWithCode() throws {
        try assertTokens("x // comment\ny", [
            .identifier, .whitespace, .comment, .newline, .identifier
        ])
    }

    // MARK: - Helper Methods

    private func tokenize(_ source: String) throws -> [Token] {
        let lexer = Lexer(source: source)
        return try lexer.tokenize()
    }

    private func assertTokens(_ source: String, _ expectedTypes: [TokenType], file: StaticString = #file, line: UInt = #line) throws {
        let tokens = try tokenize(source)

        // Filter out EOF for comparison unless it's expected
        let actualTokens = tokens.filter { $0.type != .eof }
        let expectedWithoutEOF = expectedTypes.filter { $0 != .eof }

        XCTAssertEqual(
            actualTokens.count,
            expectedWithoutEOF.count,
            "Expected \(expectedWithoutEOF.count) tokens but got \(actualTokens.count) for input: \"\(source)\"",
            file: file,
            line: line
        )

        for (index, (actual, expected)) in zip(actualTokens, expectedWithoutEOF).enumerated() {
            XCTAssertEqual(
                actual.type,
                expected,
                "Token \(index): expected \(expected) but got \(actual.type) (\(actual.lexeme)) for input: \"\(source)\"",
                file: file,
                line: line
            )
        }
    }
}
