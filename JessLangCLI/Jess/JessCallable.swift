//
//  JessCallable.swift
//  JessLangCLI
//
//  Created by Andre jones on 2/17/26.
//

import Foundation

protocol JessCallable {
    // Fancy word for the amount of args passed
    var arity: Int { get }
    func call(interpreter: Interpreter, args: [Any?]) throws -> Any?
    
}
