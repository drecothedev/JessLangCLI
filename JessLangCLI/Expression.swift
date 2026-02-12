//
//  Expression.swift
//  JessLang
//
//  Created by Andre jones on 1/31/26.
//

import Foundation

indirect enum Expr {
    case binary(left: Expr, op: Token, right: Expr)
    case grouping(Expr)
    case literal(Any)
    case unary(op: Token, right: Expr)
}

protocol ExprVisitor {
    associatedtype ReturnType

    func visitBinary(_ expr: Expr, left: Expr, op: Token, right: Expr) -> ReturnType
    func visitGrouping(_ expr: Expr, expression: Expr) -> ReturnType
    func visitLiteral(_ expr: Expr, value: Any?) -> ReturnType
    func visitUnary(_ expr: Expr, op: Token, right: Expr) -> ReturnType
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
        }
    }
}


extension Expr {
    func accept<V: ExprVisitor>(_ visitor: V) -> V.ReturnType {
        switch self {
        case let .binary(left, op, right):
            return visitor.visitBinary(self, left: left, op: op, right: right)
        case let .grouping(expression):
            return visitor.visitGrouping(self, expression: expression)
        case let .literal(value):
            return visitor.visitLiteral(self, value: value)
        case let .unary(op, right):
            return visitor.visitUnary(self, op: op, right: right)
        }
    }
}




/*
 usage:
 let printer = AstPrinter()
 let s = Expr.unary(op: Token(lexeme: "-"), right: .literal(123)).accept(printer)
 */
