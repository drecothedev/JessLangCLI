//
//  ASTPrinter.swift
//  JessLang
//
//  Created by Andre jones on 2/2/26.
//

import Foundation

struct AstPrinter: ExprVisitor {
    typealias ReturnType = String

    func visitLogical(_ expr: Expr, left: Expr, op: Token, right: Expr) throws -> String {
        "(\(op.lexeme) \(try left.accept(self)) \(try right.accept(self)))"
    }
    
    func visitCall(_ expr: Expr, callee: Expr, paren: Token, args: [Expr]) throws -> String {
        let argText = try args.map { try $0.accept(self) }.joined(separator: " ")
        let calleeText = try callee.accept(self)
        return argText.isEmpty ? "(call \(calleeText))" : "(call \(calleeText) \(argText))"
    }

    
    func print(_ expr: Expr) throws -> String {
            try expr.accept(self)
    }
    
    func visitAssign(_ expr: Expr, name: Token, value: Expr) throws -> String {
        name.lexeme
    }
    
    func visitVariable(_ expr: Expr, name: Token) throws -> String {
            name.lexeme
    }
    
    func visitBinary(_ expr: Expr, left: Expr, op: Token, right: Expr) throws -> String {
        "(\(op.lexeme) \(try left.accept(self)) \(try right.accept(self)))"
    }

    func visitGrouping(_ expr: Expr, expression: Expr) throws -> String {
        "(group \(try expression.accept(self)))"
    }

    func visitLiteral(_ expr: Expr, value: Any?) -> String {
        value.map { "\($0)" } ?? "nil"
    }

    func visitUnary(_ expr: Expr, op: Token, right: Expr) throws -> String {
        "(\(op.lexeme) \(try right.accept(self)))"
    }
    
    func parenthesize(_ name: String, _ exprs: Expr...) throws -> String {
        var parts: [String] = ["(\(name)"]

        for expr in exprs {
            parts.append(try expr.accept(self))
        }

        parts.append(")")
        return parts.joined(separator: " ")
    }
}
