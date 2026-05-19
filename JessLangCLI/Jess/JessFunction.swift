//
//  JessFunction.swift
//  JessLangCLI
//
//  Created by Andre jones on 2/17/26.
//

import Foundation

final class JessFunction: JessCallable, CustomStringConvertible {
    private let name: Token
    private let params: [Token]
    private let body: [Stmt]
    private let closure: Enviroment

    init(name: Token, params: [Token], body: [Stmt], closure: Enviroment) {
        self.name = name
        self.params = params
        self.body = body
        self.closure = closure
    }

    var arity: Int { params.count }

    func call(interpreter: Interpreter, args: [Any?]) throws -> Any? {
        // Creates a new enviroment with its current closure.
        let localEnv = Enviroment(enclosing: closure)
        
        // Defines local variables for all paramenters and args passed in. Uses a hashmap for such
        for (param, arg) in zip(params, args) {
            try localEnv.define(name: param, value: arg)
        }
        
        // Passes a series of statements in to be execuded.
        do {
            try interpreter.executeBlock(body, in: localEnv)
        } catch let returnSignal as ReturnSignal {
            return returnSignal.value
        }

        return nil
    }

    var description: String {
        "<fn \(name.lexeme)>"
    }
}
