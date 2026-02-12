//
//  Token.swift
//  JessLang
//
//  Created by Andre jones on 1/22/26.
//

import Foundation

enum LiteralValue {
    case number(Double)
    case string(String)
    case boolean(Bool)
    case none
}

enum TokenType: String {
    // Single character tokens
    case leftParent, rightParent, leftBrace, rightBrace, comma, dot, minus, plus, semicolon, slash, star
    
    // One or two character tokens
    case bang, bangEqual, equal, equalEqual, greater, greaterEqual, less, lessEqual
    
    // literals
    case identifier, string, number
    
    // keywords
    case `class`, `else`, `false`, `func`, `for`, `if`, `nil`, or, print, `return`, `super`, this, `true`, `var`, `while`, `let`, and
    
    case EOF
}

final class Token {
    let type: TokenType
    let lexeme: String
    let literal: LiteralValue?
    let line: Int
    
    init(type: TokenType, lexeme: String, literal: LiteralValue, line: Int) {
        self.type = type
        self.lexeme = lexeme
        self.literal = literal
        self.line = line
    }
    
    func toString() -> String {
        return "type: \(type), lexeme: \(lexeme)"
    }
}


