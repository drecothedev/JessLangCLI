//
//  Interpreter.swift
//  JessLangCLI
//
//  Created by Andre jones on 2/3/26.
//

import Foundation

final class Interpreter: ExprVisitor {
    typealias ReturnType = Any?

    func evaluate(_ expr: Expr) -> Any? {
        expr.accept(self)
    }

    func visitBinary(_ expr: Expr, left: Expr, op: Token, right: Expr) -> Any? {
        let l = left.accept(self)
        let r = right.accept(self)

        switch op.type {
        case .plus:
            // number + number
            if let a = l as? Double, let b = r as? Double { return a + b }
            // string + string (optional)
            if let a = l as? String, let b = r as? String { return a + b }
            // string + anything (optional)
            if let a = l as? String { return a + String(describing: r) }
            if let b = r as? String { return String(describing: l) + b }
            return nil

        case .minus:
            if let a = l as? Double, let b = r as? Double { return a - b }
            return nil

        case .star:
            if let a = l as? Double, let b = r as? Double { return a * b }
            return nil

        case .slash:
            if let a = l as? Double, let b = r as? Double { return a / b }
            return nil

        case .greater:
            if let a = l as? Double, let b = r as? Double { return a > b }
            return nil

        case .greaterEqual:
            if let a = l as? Double, let b = r as? Double { return a >= b }
            return nil

        case .less:
            if let a = l as? Double, let b = r as? Double { return a < b }
            return nil

        case .lessEqual:
            if let a = l as? Double, let b = r as? Double { return a <= b }
            return nil

        case .equalEqual:
            // Simple equality check
            return isEqual(l, r)

        case .bangEqual:
            return !isEqual(l, r)

        default:
            return nil
        }
    }

    func visitGrouping(_ expr: Expr, expression: Expr) -> Any? {
        expression.accept(self)
    }

    func visitLiteral(_ expr: Expr, value: Any?) -> Any? {
        value
    }

    func visitUnary(_ expr: Expr, op: Token, right: Expr) -> Any? {
        let r = right.accept(self)

        switch op.type {
        case .minus:
            if let n = r as? Double { return -n }
            return nil

        case .bang:
            return !isTruthy(r)

        default:
            return nil
        }
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

