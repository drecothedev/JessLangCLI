//
//  main.swift
//  JessLangCLI
//
//  Created by Andre jones on 2/2/26.

import Foundation

let args = CommandLine.arguments

if args.count > 2 {
    print("Usage: jess [script]")
    exit(64)
} else if args.count == 2 {
    Jess.runFile(path: args[1])   // ✅ this is where exit(65)/exit(70) can happen
} else {
    Jess.runPrompt()
}



