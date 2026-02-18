//
//  Expression.swift
//  JessLang
//
//  Created by Andre jones on 1/31/26.
//

import Foundation

indirect enum Expr {
    // Operations that will effect the expressions to the right and left.
    // ex: 5 + 5
    case binary(left: Expr, op: Token, right: Expr)
    
    // Experessions that are wrapped in parenthesis, brackets, etc.
    // ex: (5 * 5)
    case grouping(Expr)
    
    // Any value that is not tied to a variable
    // ex: 42, "Hello world"
    case literal(Any?)
    
    // A value that is being effected by the token next to it
    // ex: -42, ++i, etc. 
    case unary(op: Token, right: Expr)
    
    // Evaluates a variable representing an expression
    case variable(Token)
    
    case assign(name: Token, value: Expr)
    
    case logical(l: Expr, op: Token, r: Expr)
    
    case call(callee: Expr, paren: Token, args: [Expr])
    
}

protocol ExprVisitor {
    associatedtype ReturnType

    func visitBinary(_ expr: Expr, left: Expr, op: Token, right: Expr) throws -> ReturnType
    func visitGrouping(_ expr: Expr, expression: Expr) throws -> ReturnType
    func visitLiteral(_ expr: Expr, value: Any?) throws -> ReturnType
    func visitUnary(_ expr: Expr, op: Token, right: Expr) throws -> ReturnType
    func visitVariable(_ expr: Expr, name: Token) throws -> ReturnType
    func visitAssign(_ expr: Expr, name: Token, value: Expr) throws -> ReturnType
    func visitLogical(_ expr: Expr, left: Expr, op: Token, right: Expr) throws -> ReturnType
    func visitCall(_ expr: Expr, callee: Expr, paren: Token, args: [Expr]) throws -> ReturnType
}




class Expression {
    
    let currentExpr: Expr
    
    init(currentExpr: Expr) {
        self.currentExpr = currentExpr
    }
    
    // acceptMethod
    func accept(visitor: Expr) {
        switch visitor {
        case .binary(let left, let op, let right):
            print("Binary: \(left), \(op), \(right)")
            
        case .grouping(_):
            print("")
        case .literal(_):
            print("D")
        case .unary(_, _):
            print("S")
        case .variable(_):
            print("")
        case .assign(name: let name, value: let value):
            print("")
        case .logical(l: let l, op: let op, r: let r):
            print("")
        case .call(callee: let callee, paren: let paren, args: let args):
            print("")
        }
    }
    
    func printExpr(_ expr: Expr) -> String {
        switch expr {
        case let .binary(left, op, right):
            return "(\(op.lexeme) \(printExpr(left)) \(printExpr(right)))"

        case let .grouping(expr):
            return "(group \(printExpr(expr)))"

        case let .literal(value):
            return "\(value ?? "nil")"

        case let .unary(op, right):
            return "(\(op.lexeme) \(printExpr(right)))"
        case .variable(_):
            return ""
        case .assign(name: let name, value: let value):
            return ""
        case .logical(l: let l, op: let op, r: let r):
            return ""
        case .call(callee: let callee, paren: let paren, args: let args):
            return "" 
        }
    }
}


extension Expr {
    func accept<V: ExprVisitor>(_ visitor: V) throws -> V.ReturnType {
        switch self {
        case let .binary(left, op, right):
            return try visitor.visitBinary(self, left: left, op: op, right: right)
        case let .grouping(expression):
            return try visitor.visitGrouping(self, expression: expression)
        case let .literal(value):
            return try visitor.visitLiteral(self, value: value)
        case let .unary(op, right):
            return try visitor.visitUnary(self, op: op, right: right)
        case .variable(let name):
            return try visitor.visitVariable(self, name: name)
        case .assign(name: let name, value: let value):
            return try visitor.visitAssign(self, name: name, value: value)
        case let .logical(left, op, right):
            return try visitor.visitLogical(self, left: left, op: op, right: right)
        case let .call(callee, paren, args):
            return try visitor.visitCall(self, callee: callee, paren: paren, args: args)

        }
    }
}




/*
 usage:
 let printer = AstPrinter()
 let s = Expr.unary(op: Token(lexeme: "-"), right: .literal(123)).accept(printer)
 */
