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

    func parseExpressions() -> Expr? {
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
    
    /// Returns an expression or nil if a syntax error occurred.
    func parseStatements() -> [Stmt] {
        var statements: [Stmt] = []

        while !isAtEnd {
            if let stmt = declaration() {     // or statement() if you haven’t added declarations yet
                statements.append(stmt)
            }
        }

        return statements
    }
    
    private func declaration() -> Stmt? {
        do {
            if match(.func) {
                return try function(kind: "function")
            }
            if match(.var) || match(.let) {
                return try varDeclaration()
            }
    
            
            return try statement()
        } catch is ParseError {
            synchronize()
            return nil
        } catch {
            print(error)
            synchronize()
            return nil
        }
    }
    
    private func varDeclaration() throws -> Stmt {
        let name = try consume(.identifier, message: "Expect variable name.")
        
        var initializer: Expr? = nil

        if match(.equal) {
            initializer = try expression()
        }

        let _ = try consume(.semicolon, message: "Expect ';' after variable declaration.")

        return .variable(name: name, initializer: initializer)
    }
    
    private func function(kind: String) throws -> Stmt {
        let name = try consume(.identifier, message: "Expect \(kind) name.")
        _ = try consume(.leftParent, message: "Expect '(' after \(kind) name.")

        var parameters: [Token] = []
        if !check(.rightParent) {
            repeat {
                if parameters.count >= 255 {
                    _ = error(peek(), "Can't have more than 255 parameters.")
                }
                parameters.append(try consume(.identifier, message: "Expect parameter name."))
            } while match(.comma)
        }

        _ = try consume(.rightParent, message: "Expect ')' after parameters.")
        _ = try consume(.leftBrace, message: "Expect '{' before \(kind) body.")
        let body = try block()

        return .function(name: name, params: parameters, body: body)
    }

    private func returnStatement() throws -> Stmt {
        let keyword = previous()
        var value: Expr? = nil

        if !check(.semicolon) {
            value = try expression()
        }

        _ = try consume(.semicolon, message: "Expect ';' after return value.")
        return .return(keyword: keyword, value: value)
    }


    
    private func statement() throws -> Stmt {
        if match(.print) {
            return try printStatement()
        }
        
        if match(.return) {
            return try returnStatement()
        }
        
        if match(.while) { return try whileStatement() }
        
        if match(.for) { return try forStatement() }
        
        if match(.leftBrace) {
            return Stmt.block(try block())
        }
        
        if match(.if) { return try ifStatement() }
        
        return try expressionStatement()
    }
    
    private func forStatement() throws -> Stmt {
        _ = try consume(.leftParent, message: "Expect '(' after 'for'.")
        
        var initializer: Stmt?
        
        if match(.semicolon) {
            initializer = nil
        } else if match(.var) {
            initializer = try varDeclaration()
        } else {
            initializer = try expressionStatement()
        }
        
        var condition: Expr? = nil
        
        if !check(.semicolon) {
            condition = try expression()
        }
        _ = try consume(.semicolon, message: "Expect ';' after loop condition.")
        
        var increment: Expr? = nil
        
        if !check(.rightParent) {
            increment = try expression()
        }
        
        _ = try consume(.rightParent, message: "Expect ')' after for clasues.")
        
        var body = try statement()
        
        if let increment = increment {
            body = Stmt.block([body, Stmt.expression(increment)])
        }
        
        if condition == nil {
            condition = Expr.literal(true)
        }
        
        if let condition = condition {
            body = Stmt.while(condition, body)
        }
        
        if let initializer = initializer {
            body = Stmt.block([initializer, body])
        }
        
        
        
        return body
    }
    
    private func whileStatement() throws -> Stmt {
        _ = try consume(.leftParent, message: "Expect '(' after 'while'.")
        
        let condition = try expression()
        
        _ = try consume(.rightParent, message: "Expect ')' after condition")
        
        let body = try statement()
        
        return Stmt.while(condition, body)
        
    }
    
    private func ifStatement() throws -> Stmt {
        _ = try consume(.leftParent, message: "Expect '(' after 'if'")
        let condition = try expression()
        _ = try consume(.rightParent, message: "Expect ')' after if condition")
        
        let thenBranch = try statement()
        var elseBranch: Stmt? = nil
        
        if match(.else) {
            elseBranch = try statement()
            return Stmt.if(condition, thenBranch, elseBranch)
        }
        
        return Stmt.if(condition, thenBranch, nil)
    }
    
    private func printStatement() throws -> Stmt {
        let expr = try expression()
        let _ = try consume(.semicolon, message: "Expect ';' after expression.")
        return .print(expr)
    }

    private func expressionStatement() throws -> Stmt {
        let expr = try expression()
        let _ = try consume(.semicolon, message: "Expect ';' after expression")
        
        return Stmt.expression(expr)
    }
    
    private func block() throws -> [Stmt] {
        var statements: [Stmt] = []
        
        while !check(.rightBrace) && !isAtEnd {
            if let stmt = declaration() {
                statements.append(stmt)
            }
        }
        
        _ = try consume(.rightBrace, message: "Expected '}' after block. Please add this to close scope")
        return statements
    }
    
    private func assignment() throws -> Expr {
        let expr = try or()

        if match(.equal) {
            let equals = previous()
            let value = try assignment()

            if case .variable(let name) = expr {
                return .assign(name: name, value: value)
            }

            throw error(equals, "Invalid assignment target.")
        }

        return expr
    }
    
    private func or() throws -> Expr {
        var expr = try and()
        
        while match(.or) {
            let op = previous()
            let right = try and()
            expr = Expr.logical(l: expr, op: op, r: right)
        }
        
        return expr
    }
    
    private func and() throws -> Expr {
        var expr = try equality()
        
        while match(.and) {
            let op = previous()
            let right = try equality()
            expr = Expr.logical(l: expr, op: op, r: right)
        }
        
        return expr
    }
    
    // MARK: - Grammar

    private func expression() throws -> Expr {
        try assignment()
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
        return try call()
    }

    private func finishCall(callee: Expr) throws -> Expr {
        var arguments: [Expr] = []

        if !check(.rightParent) {
            repeat {
                if arguments.count >= 255 {
                    _ = error(peek(), "Can't have more than 255 arguments.")
                }
                arguments.append(try expression())
            } while match(.comma)
        }

        let paren = try consume(.rightParent, message: "Expect ')' after arguments.")
        return .call(callee: callee, paren: paren, args: arguments)
    }

    
    private func call() throws -> Expr {
        var expr = try primary()
        
        while true {
            if match(.leftParent) {
                expr = try finishCall(callee: expr)
            } else {
                break
            }
        }
        
        return expr
    }

    private func primary() throws -> Expr {
        if match(.false) { return .literal(false) }
        if match(.true)  { return .literal(true) }
        if match(.nil)   { return .literal(nil) }

        if match(.number, .string) {
            return .literal(previous().literal)
        }

        if match(.identifier) {
            return .variable(previous())
        }

        if match(.leftParent) {
            let expr = try expression()
            try consume(.rightParent, message: "Expect ')' after expression.")
            return .grouping(expr)
        }

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
    
    // Takes a look at the current token
    private func peek() -> Token {
        guard current <= tokens.count - 1 else { return Token().defaultToken() }
        return tokens[current]
    }
    
    // Checks to previous token
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
        if token.type == .EOF {
            Jess.report(line: token.line, where: " at end", message: message)
        } else {
            Jess.report(line: token.line, where: " at '\(token.lexeme)'", message: message)
        }
        return ParseError()
    }


    // MARK: - Synchronization (panic mode recovery)

    private func synchronize() {
        _ = advance()

        while !isAtEnd {
            if previous().type == .semicolon { return }

            switch peek().type {
            case .class, .func, .var, .for, .if, .while, .print, .return, .let:
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
