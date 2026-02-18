//
//  Interpreter.swift
//  JessLangCLI
//
//  Created by Andre jones on 2/3/26.
//

import Foundation

final class Interpreter: ExprVisitor {
    typealias ReturnType = Any?

    private let environment = Enviroment()

    // MARK: - Top-level

    func interpret(statements: [Stmt]) {
        do {
            for statement in statements {
                try execute(statement)
            }
        } catch let err as RuntimeError {
            Jess.runtimeError(err)
        } catch {
            print("Unexpected error: \(error)")
        }
    }

    private func execute(_ stmt: Stmt) throws {
        switch stmt {
        case .expression(let expr):
            _ = try evaluate(expr)

        case .print(let expr):
            let value = try evaluate(expr)
            print(stringify(obj: value))

        case .variable(let name, let initializer):
            let value: Any? = try initializer.flatMap { try evaluate($0) }
            try environment.define(name: name, value: value)
        }
    }

    // MARK: - Expr evaluation

    func evaluate(_ expr: Expr) throws -> Any? {
        try expr.accept(self)
    }

    // Assignment expression: a = <expr>
    func visitAssign(_ expr: Expr, name: Token, value: Expr) throws -> Any? {
        let newValue = try evaluate(value)
        try environment.assign(name: name, value: newValue)
        return newValue
    }

    func visitVariable(_ expr: Expr, name: Token) throws -> Any? {
        try environment.get(name: name)
    }

    func visitBinary(_ expr: Expr, left: Expr, op: Token, right: Expr) throws -> Any? {
        let l = try left.accept(self)
        let r = try right.accept(self)

        switch op.type {
        case .plus:
            if let a = l as? Double, let b = r as? Double { return a + b }
            if let a = l as? String, let b = r as? String { return a + b }
            if let a = l as? String { return a + String(describing: r) }
            if let b = r as? String { return String(describing: l) + b }
            throw RuntimeError(token: op, message: "Operands must be two numbers or strings.")

        case .minus:
            if let a = l as? Double, let b = r as? Double { return a - b }
            throw RuntimeError(token: op, message: "Operands must be numbers.")

        case .star:
            if let a = l as? Double, let b = r as? Double { return a * b }
            throw RuntimeError(token: op, message: "Operands must be numbers.")

        case .slash:
            if let a = l as? Double, let b = r as? Double { return a / b }
            throw RuntimeError(token: op, message: "Operands must be numbers.")

        case .greater:
            if let a = l as? Double, let b = r as? Double { return a > b }
            throw RuntimeError(token: op, message: "Operands must be numbers.")

        case .greaterEqual:
            if let a = l as? Double, let b = r as? Double { return a >= b }
            throw RuntimeError(token: op, message: "Operands must be numbers.")

        case .less:
            if let a = l as? Double, let b = r as? Double { return a < b }
            throw RuntimeError(token: op, message: "Operands must be numbers.")

        case .lessEqual:
            if let a = l as? Double, let b = r as? Double { return a <= b }
            throw RuntimeError(token: op, message: "Operands must be numbers.")

        case .equalEqual:
            return isEqual(l, r)

        case .bangEqual:
            return !isEqual(l, r)

        default:
            return nil
        }
    }

    func visitGrouping(_ expr: Expr, expression: Expr) throws -> Any? {
        try expression.accept(self)
    }

    func visitLiteral(_ expr: Expr, value: Any?) throws -> Any? {
        // If literals are stored as LiteralValue, unwrap them.
        if let lit = value as? LiteralValue {
            switch lit {
            case .number(let d): return d
            case .string(let s): return s
            case .boolean(let b): return b
            case .none: return nil
            }
        }
        return value
    }

    func visitUnary(_ expr: Expr, op: Token, right: Expr) throws -> Any? {
        let r = try right.accept(self)

        switch op.type {
        case .minus:
            if let n = r as? Double { return -n }
            throw RuntimeError(token: op, message: "Operand must be a number.")

        case .bang:
            return !isTruthy(r)

        default:
            return nil
        }
    }

    // MARK: - Printing

    func stringify(obj: Any?) -> String {
        guard let obj else { return "nil" }

        if let d = obj as? Double {
            var text = String(d)
            if text.hasSuffix(".0") { text.removeLast(2) }
            return text
        }

        return String(describing: obj)
    }

    // MARK: - Helpers

    private func isTruthy(_ value: Any?) -> Bool {
        if value == nil { return false }
        if let b = value as? Bool { return b }
        return true
    }

    private func isEqual(_ a: Any?, _ b: Any?) -> Bool {
        switch (a, b) {
        case (nil, nil): return true
        case let (x as Double, y as Double): return x == y
        case let (x as Bool, y as Bool): return x == y
        case let (x as String, y as String): return x == y
        default: return false
        }
    }
}


