//
//  Enviroment.swift
//  JessLangCLI
//
//  Created by Andre jones on 2/17/26.
//

import Foundation

class Enviroment {
    private var values: [String: Any] = [:]
    
    func define(name: Token, value: Any?) throws {
        if values[name.lexeme] != nil {
            throw RuntimeError(token: name, message: "Variable called \(name.lexeme) already exist. Please choose a different name. ")
        }
        values[name.lexeme] = value
    }
    
    func get(name: Token) throws -> Any? {
        if values.keys.contains(name.lexeme) {
            return values[name.lexeme]
        }
        
        throw RuntimeError(token: name, message: "\(name.lexeme) is undefined. define it first, or check your spelling")
    }
    
    func assign(name: Token, value: Any?) throws {
        if values.keys.contains(name.lexeme) {
            values[name.lexeme] = value
            return
        }
        
        throw RuntimeError(token: name, message: "You are trying to assign a value to a variable not yet declared. Create a new variable or ensure your \(name.lexeme) exist in this scope.")
    }
}
