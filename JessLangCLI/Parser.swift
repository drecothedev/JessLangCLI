//
//  Parser.swift
//  JessLangCLI
//
//  Created by Andre jones on 2/2/26.
//

import Foundation


// “Signal” error type used to unwind the parser.
struct ParseError: Error {}

final class Parser {
    private let tokens: [Token]
    private var current = 0

    init(tokens: [Token]) {
        self.tokens = tokens
    }

    // MARK: - Public API (book style)

    /// Returns an expression or nil if a syntax error occurred.
    func parse() -> Expr? {
        do {
            return try expression()
        } catch is ParseError {
            synchronize()
            return nil
        } catch {
            // Unexpected errors (shouldn't happen often)
            print(error)
            return nil
        }
    }

    // MARK: - Grammar

    private func expression() throws -> Expr {
        try equality()
    }

    private func equality() throws -> Expr {
        try parseBinary(next: comparison, operators: [.bangEqual, .equalEqual])
    }

    private func comparison() throws -> Expr {
        try parseBinary(next: term, operators: [.greater, .greaterEqual, .less, .lessEqual])
    }

    private func term() throws -> Expr {
        try parseBinary(next: factor, operators: [.minus, .plus])
    }

    private func factor() throws -> Expr {
        try parseBinary(next: unary, operators: [.slash, .star])
    }

    private func unary() throws -> Expr {
        if match(.bang, .minus) {
            let op = previous()
            let right = try unary()
            return .unary(op: op, right: right)
        }
        return try primary()
    }

    private func primary() throws -> Expr {
        if match(.false) { return .literal(false) }
        if match(.true)  { return .literal(true) }
        if match(.nil)   { return .literal(nil) }

        if match(.number, .string) {
            return .literal(previous().literal)
        }

        if match(.leftParent) {
            let expr = try expression()
            try consume(.rightParent, message: "Expect ')' after expression.")
            return .grouping(expr)
        }

        // Book: error(peek(), "Expect expression.")
        throw error(peek(), "Expect expression.")
    }

    // MARK: - Binary helper

    private func parseBinary(
        next: () throws -> Expr,
        operators: [TokenType]
    ) throws -> Expr {
        var expr = try next()

        while match(operators) {
            let op = previous()
            let right = try next()
            expr = .binary(left: expr, op: op, right: right)
        }

        return expr
    }

    // MARK: - Token helpers

    @discardableResult
    private func match(_ types: TokenType...) -> Bool {
        match(types)
    }

    @discardableResult
    private func match(_ types: [TokenType]) -> Bool {
        for type in types where check(type) {
            advance()
            return true
        }
        return false
    }

    private func check(_ type: TokenType) -> Bool {
        !isAtEnd && peek().type == type
    }

    @discardableResult
    private func advance() -> Token {
        if !isAtEnd { current += 1 }
        return previous()
    }

    private var isAtEnd: Bool {
        peek().type == .EOF
    }

    private func peek() -> Token {
        guard current <= tokens.count - 1 else { return Token().defaultToken() }
        return tokens[current]
    }

    private func previous() -> Token {
        precondition(current > 0, "previous() called when current == 0")
        return tokens[current - 1]
    }

    // MARK: - Error reporting (book style)

    private func consume(_ type: TokenType, message: String) throws -> Token {
        if check(type) { return advance() }
        throw error(peek(), message)
    }

    /// Report error to user and return a ParseError to throw.
    private func error(_ token: Token, _ message: String) -> ParseError {
        JessLang.error(token: token, message: message)
        return ParseError()
    }

    // MARK: - Synchronization (panic mode recovery)

    private func synchronize() {
        _ = advance()

        while !isAtEnd {
            if previous().type == .semicolon { return }

            switch peek().type {
            case .class, .func, .var, .for, .if, .while, .print, .return:
                return
            default:
                break
            }

            _ = advance()
        }
    }
}

// MARK: - Error reporter (like Lox.error)

enum JessLang {
    static func report(_ line: Int, _ whereText: String, _ message: String) {
        print("[line \(line)] Error\(whereText): \(message)")
    }

    static func error(token: Token, message: String) {
        if token.type == .EOF {
            report(token.line, " at end", message)
        } else {
            report(token.line, " at '\(token.lexeme)'", message)
        }
    }
}
