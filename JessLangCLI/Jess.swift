//
//  Jess.swift
//  JessLang
//
//  Created by Andre jones on 1/22/26.
//

import Foundation

/*
 This file will act as the main manager of the language. Meaning it will use all of the helper functions
 */

import Foundation

class Jess {

    // MARK: - Error Flags
    static var hadError = false
    static var hadRuntimeError = false

    // MARK: - Entry Points

    static func runFile(path: String) {
        do {
            let source = try String(contentsOfFile: path, encoding: .utf8)
            run(source)

            if hadError { exit(65) }
            if hadRuntimeError { exit(70) }

        } catch {
            print("Could not read file at path: \(path)")
            exit(74)
        }
    }

    static func runPrompt() {
        while true {
            print("> ", terminator: "")
            guard let line = readLine() else { break }

            run(line)
            hadError = false   // reset for REPL
        }
    }

    static func run(_ source: String) {
        let scanner = Scanner(source: source)
        let tokens = scanner.scanTokens()
        
        let parser = Parser(tokens: tokens)
        
        // Parse the whole program
        let statements = parser.parseStatements()
        
        if hadError { return }
        
        let interpreter = Interpreter()
        interpreter.interpret(statements: statements)
    }

    // MARK: - Compile Errors

    static func error(line: Int, message: String) {
        report(line: line, where: "", message: message)
    }

    static func report(line: Int, where location: String, message: String) {
        print("[line \(line)] Error\(location): \(message)")
        hadError = true
    }

    // MARK: - Runtime Errors

    static func runtimeError(_ error: RuntimeError) {
        print("\(error.message)\n[line \(error.token.line)]")
        hadRuntimeError = true
    }
}


