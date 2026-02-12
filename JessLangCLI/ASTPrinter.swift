//
//  ASTPrinter.swift
//  JessLang
//
//  Created by Andre jones on 2/2/26.
//

import Foundation

struct AstPrinter: ExprVisitor {
    typealias ReturnType = String
    
    func print(_ expr: Expr) -> String {
            expr.accept(self)
    }

    func visitBinary(_ expr: Expr, left: Expr, op: Token, right: Expr) -> String {
        "(\(op.lexeme) \(left.accept(self)) \(right.accept(self)))"
    }

    func visitGrouping(_ expr: Expr, expression: Expr) -> String {
        "(group \(expression.accept(self)))"
    }

    func visitLiteral(_ expr: Expr, value: Any?) -> String {
        value.map { "\($0)" } ?? "nil"
    }

    func visitUnary(_ expr: Expr, op: Token, right: Expr) -> String {
        "(\(op.lexeme) \(right.accept(self)))"
    }
    
    func parenthesize(_ name: String, _ exprs: Expr...) -> String {
        var parts: [String] = ["(\(name)"]

        for expr in exprs {
            parts.append(expr.accept(self))
        }

        parts.append(")")
        return parts.joined(separator: " ")
    }
}
