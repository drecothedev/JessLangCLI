//
//  JessClass.swift
//  JessLangCLI
//
//  Created by Andre jones on 2/23/26.
//

import Foundation

class JessClass: JessCallable {
    var name: String
    var arity: Int {
        return 0
    }
    
    init(name: String) {
        self.name = name
    }

    func call(interpreter: Interpreter, args: [Any?]) throws -> Any? {
        let instance: JessInstance = JessInstance(klass: self)
        return instance
    }
}
