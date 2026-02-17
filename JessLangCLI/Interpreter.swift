//
//  Interpreter.swift
//  JessLangCLI
//
//  Created by Andre jones on 2/3/26.
//

import Foundation

final class Interpreter: ExprVisitor {
    typealias ReturnType = Any?

    func evaluate(_ expr: Expr) throws -> Any? {
        try expr.accept(self)
    }

    func visitBinary(_ expr: Expr, left: Expr, op: Token, right: Expr) throws -> Any? {
        let l = try left.accept(self)
        let r = try right.accept(self)

        switch op.type {
        case .plus:
            // number + number
            if let a = l as? Double, let b = r as? Double { return a + b }
            // string + string (optional)
            if let a = l as? String, let b = r as? String { return a + b }
            // string + anything (optional)
            if let a = l as? String { return a + String(describing: r) }
            if let b = r as? String { return String(describing: l) + b }
            throw RuntimeError(token: op, message: "Operands must be two numbers or strings.")

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

    func visitGrouping(_ expr: Expr, expression: Expr) throws -> Any? {
        try expression.accept(self)
    }

    func visitLiteral(_ expr: Expr, value: Any?) -> Any? {
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
            return nil

        case .bang:
            return !isTruthy(r)

        default:
            return nil
        }
    }
    
    func interpret(expression: Expr) {
        do {
            let val = try evaluate(expression)
            print(stringify(obj: val))
        } catch let error as RuntimeError {
            Jess.runtimeError(error)
        } catch {
            print("Unexpected error: \(error)")
        }
    }

    
    func stringify(obj: Any?) -> String {
        guard let obj = obj else { return "nil" }
        
        if let objAsDouble = obj as? Double {
            var text = String(objAsDouble)
            let startIdx = text.startIndex
            let secondToLastIdx = text.index(text.endIndex, offsetBy: -2)
            let lastIdx = text.index(text.endIndex, offsetBy: -1)
            if text[secondToLastIdx] == "." && text[lastIdx] == "0" {
                text = String(text[startIdx...secondToLastIdx])
            }
            
            return text
        }
        
        return obj as? String ?? ""
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
    
    private func checkNumberOperands(op: Token, l: Any?, r: Any?) throws {
        guard let left = l as? Double else { return }
        guard let right = r as? Double else { return }
        
        let runtimerError = RuntimeError(token: op, message: "Please use only numbers for arithmetic")
        throw runtimerError
    }
}

