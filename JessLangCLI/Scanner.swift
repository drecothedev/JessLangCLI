//
//  Scanner.swift
//  JessLang
//
//  Created by Andre jones on 1/22/26.
//

import Foundation

class Scanner {
    var source: String
    var tokens: [Token] = []
    private var start: Int = 0
    private var current: Int = 0
    private var line: Int = 1
    init(source: String) {
        self.source = source
    }
    
    func scanTokens() -> [Token] {
        print("Scanning Tokens...")
        while !isAtEnd() {
            start = current
            // Scan each token
            scanToken()
        }
        tokens.append(Token(type: .EOF, lexeme: "", literal: .none, line: line))
        for token in tokens {
            print(token.type)
        }
        return tokens
    }

    func isAtEnd() -> Bool {
        return current >= source.count
    }
    
    // Scans tokens. This will check for the character inputted and based on that input the token will either be added or handled with some method.
    func scanToken() {
        let c = advance()
        switch c {
        case "(":
            addToken(type: .leftParent)
            print("Token scanned: \(c)")
        case ")":
            addToken(type: .rightParent)
            print("Token scanned: \(c)")
        case "{":
            addToken(type: .leftBrace)
            print("Token scanned: \(c)")
        case "}":
            addToken(type: .rightBrace)
            print("Token scanned: \(c)")
        case ",":
            addToken(type: .comma)
            print("Token scanned: \(c)")
        case ".":
            addToken(type: .dot)
            print("Token scanned: \(c)")
        case "-":
            addToken(type: .minus)
            print("Token scanned: \(c)")
        case "+":
            addToken(type: .plus)
            print("Token scanned: \(c)")
        case ";":
            addToken(type: .semicolon)
            print("Token scanned: \(c)")
        case "*":
            addToken(type: .star)
            print("Token scanned: \(c)")
        case "!":
            addToken(type: match(expectedValue: "=") ? .bangEqual : .bang)
        case ">":
            addToken(type: match(expectedValue: "=") ? .greaterEqual : .bang)
        case "<":
            addToken(type: match(expectedValue: "=") ? .lessEqual : .lessEqual)
        case "=":
            addToken(type: match(expectedValue: "=") ? .equalEqual : .bang)
        case "/":
            if match(expectedValue: "/") {
                // A commment goes until the end of the line
                while peek() != "\n" && !isAtEnd() {
                    let _ = advance()
                }
            } else {
                addToken(type: .slash)
            }
            break
        case " ":
            print("Ignoring white space")
        case "\r":
            print("")
        case "\t":
            print("")
            break
        case "\n":
            line += 1
            break
        case "\"":
            string()
            break
        default:
            if isDigit(c) {
                number()
            } else if isAlpha(c) {
                identifier()
            }
            else {
                print(JessError(line: line, message: "Unexpected character: \(c)"))
            }
            break
        }

    }
    
    // Moves index to next charcter
    func advance() -> Character {
        let idx = source.index(source.startIndex, offsetBy: current)
        current += 1
        return source[idx]
    }

    
    
    func addToken(type: TokenType) {
        addToken(type: type, literal: .none)
        print("token added: \(type)")
    }
    
    // Adds token based on literal type.
    func addToken(type: TokenType, literal: LiteralValue) {
        let startIdx = source.index(source.startIndex, offsetBy: start)
        let currentIdx = source.index(source.startIndex, offsetBy: current)
        let text = String(source[startIdx..<currentIdx])
        tokens.append(Token(type: type, lexeme: text, literal: literal, line: line))
        print("token added: \(type) literal: \(literal) lexeme: \(text)") // ✅
    }


    
    // For lexemes that may rely on the presence of another character we check for the presence of that character. For example, if the current char is '!' we want to see if the character next to it is '=' so we can handle accordingly
    func match(expectedValue: Character) -> Bool {
        guard current <= source.count else { return false }
        if source[source.index(source.startIndex, offsetBy: current)] != expectedValue {
            return false
        }
        current += 1
        return true
    }
    
    func peek() -> Character {
        if isAtEnd() { return "\0" }
        return source[source.index(source.startIndex, offsetBy: current)]
    }
    
    // Handles string literals
    func string() {
        while peek() != "\"" && !isAtEnd() {
            if peek() == "\n" {
                line += 1
            }
            let _ = advance()
        }
        
        if isAtEnd() {
            print(JessError(line: line, message: "Unterminated String"))
            return
        }
        
        // The closing ".
        let _ = advance()
        
        let startIdx = source.index(source.startIndex, offsetBy: start + 1)
        let endIdx = source.index(source.startIndex, offsetBy: current - 1)
        let value = source[startIdx..<endIdx]
        addToken(type: .string, literal: .string(String(value)))
        print(value)
    }
    
    func isDigit(_ c: Character) -> Bool {
        return c >= "0" && c <= "9"
    }
    
    func number() {
        while isDigit(peek()) {
            let _ = advance()
        }
        
        // Look for fractional part
        if (peek() == "." && isDigit(peekNext())) {
            let _ = advance()
            
            while isDigit(peek()) {
                let _ = advance()
            }
        }
        
        let startIdx = source.index(source.startIndex, offsetBy: start)
        let endIdx = source.index(source.startIndex, offsetBy: current)
        let value = String(source[startIdx..<endIdx])
    
        addToken(type: .number, literal: .number(Double(value) ?? 0.0))
    }
    
    func peekNext() -> Character {
        if current + 1 >= source.count {
            return "\0"
        }
        let next = source.index(source.startIndex, offsetBy: current + 1)
        return source[next]
    }
    
    //
    func identifier() {
        while peek().isLetter || peek().isNumber {
            let _ = advance()
        }
        
        let startIdx = source.index(source.startIndex, offsetBy: start)
        let currentIdx = source.index(source.startIndex, offsetBy: current - 1)
        let text = source[startIdx...currentIdx]
        var type = keywords[String(text)]
        if type == nil {
            type = .identifier
        }
        
        addToken(type: type ?? .EOF)
    }
    
    func isAlpha(_ c: Character) -> Bool {
        return c >= "a" && c <= "z" ||
        c >= "A" && c <= "Z" ||
        c == "_"
    }
    
    
    func isAlphaNumeric(_ c: Character) -> Bool {
        return isAlpha(c) || isDigit(c)
    }
    
    let keywords: [String: TokenType] = [
        "and": .and,
        "class": .class,
        "else": .else,
        "false": .false,
        "for": .for,
        "func": .func,
        "if": .if,
        "nil": .nil,
        "or": .or,
        "print": .print,
        "return": .return,
        "super": .super,
        "this": .this,
        "true": .true,
        "var": .var,
        "while": .while
    ]

}

