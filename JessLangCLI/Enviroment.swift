//
//  Enviroment.swift
//  JessLangCLI
//
//  Created by Andre jones on 2/17/26.
//

import Foundation

class Enviroment {
    private var values: [String: Any] = [:]
    var enclosing: Enviroment?
    
    init() {
        self.enclosing = nil
    }

    init(enclosing: Enviroment) {
        self.enclosing = enclosing
    }


    func define(name: Token, value: Any?) throws {
        if values.keys.contains(name.lexeme) {
            throw RuntimeError(token: name, message: "Variable called \(name.lexeme) already exist. Please choose a different name. ")
        }
        values[name.lexeme] = value ?? NSNull()
    }

    func get(name: Token) throws -> Any? {
        if values.keys.contains(name.lexeme) {
            let stored = values[name.lexeme]
            return stored is NSNull ? nil : stored
        }

        if let enclosing = enclosing {
            return try enclosing.get(name: name)
        }

        throw RuntimeError(token: name, message: "\(name.lexeme) is undefined. define it first, or check your spelling")
    }

    func assign(name: Token, value: Any?) throws {
        if values.keys.contains(name.lexeme) {
            values[name.lexeme] = value ?? NSNull()
            return
        }

        if let enclosing = enclosing {
            try enclosing.assign(name: name, value: value)
            return
        }

        throw RuntimeError(token: name, message: "You are trying to assign a value to a variable not yet declared. Create a new variable or ensure your \(name.lexeme) exist in this scope.")
    }
}

